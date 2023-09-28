# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function get_working_dir {
    return (Get-Location | Foreach-Object { $_.Path })
}

function is_directory {
    param (
        [string] $file
    )
    if ((fileexists "$file")) {
        return (Get-Item "$file" -Force) -is [System.IO.DirectoryInfo]
    }
    return $FALSE
}

# Source code: https://gist.github.com/dkarzon/a7a7e98a42dde86fca9e
function resize_image {
    param(
        [string]$src,
        [string]$dest,
        [int]$width,
        [int]$height,
        [int]$scale
    )

    if ((fileexists "$src")) {
        # Add System.Drawing assembly
        Add-Type -AssemblyName System.Drawing

        # Open image file
        $img = [System.Drawing.Image]::FromFile((Get-Item $src))

        # Define new resolution
        if ($width -gt 0) {
            [int]$new_width = $width
        } elseif ($scale -gt 0) {
            [int]$new_width = $img.Width * ($scale / 100)
        } else {
            [int]$new_width = $img.Width / 2
        }
        if ($height -gt 0) {
            [int]$new_height = $height
        } elseif($scale -gt 0) {
            [int]$new_height = $img.Height * ($scale / 100)
        } else {
            [int]$new_height = $img.Height / 2
        }

        # Create empty canvas for the new image
        $img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)

        # Draw new image on the empty canvas
        $graph = [System.Drawing.Graphics]::FromImage($img2)
        $graph.DrawImage($img, 0, 0, $new_width, $new_height)

        $graph.Dispose()
        $img.Dispose()

        # Save the image
        if ($dest -ne "") {
            $img2.Save($dest);
            $img2.Dispose()
        }
    }
}

function icon_extractor {
    param (
        [string] $file,
        [string] $dest,
        [switch] $display
    )
    if ((fileexists "$file") -and (((fileextension "$file") -eq ".lnk") -or ((fileextension "$file") -eq ".exe"))) {
        if (-not [string]::IsNullOrEmpty("${dest}") -and ((fileextension "$dest") -eq ".ico") -and !(fileexists "${dest}")) {
            # Source code from https://www.powershellgallery.com/packages/IconExport/1.0.1/Content/IconExport.psm1
            $code = '
            using System;
            using System.Drawing;
            using System.Runtime.InteropServices;
            using System.IO;
            
            namespace System {
                public class IconExtractor {
                    public static Icon Extract(string file, int number, bool largeIcon) {
                        IntPtr large;
                        IntPtr small;
                        ExtractIconEx(file, number, out large, out small, 1);
                        try { return Icon.FromHandle(largeIcon ? large : small); }
                        catch { return null; }
                    }
                    [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
                    private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
                }
            }
            
            public class PngIconConverter
            {
                public static bool Convert(System.Drawing.Bitmap input_bit, string output_icon, int size, bool keep_aspect_ratio = false)
                {
                    System.IO.Stream output_stream = new System.IO.FileStream(output_icon, System.IO.FileMode.OpenOrCreate);
                    if (input_bit != null)
                    {
                        int width, height;
                        if (keep_aspect_ratio)
                        {
                            width = size;
                            height = input_bit.Height / input_bit.Width * size;
                        }
                        else
                        {
                            width = height = size;
                        }
                        System.Drawing.Bitmap new_bit = new System.Drawing.Bitmap(input_bit, new System.Drawing.Size(width, height));
                        if (new_bit != null)
                        {
                            System.IO.MemoryStream mem_data = new System.IO.MemoryStream();
                            new_bit.Save(mem_data, System.Drawing.Imaging.ImageFormat.Png);

                            System.IO.BinaryWriter icon_writer = new System.IO.BinaryWriter(output_stream);
                            if (output_stream != null && icon_writer != null)
                            {
                                icon_writer.Write((byte)0);
                                icon_writer.Write((byte)0);
                                icon_writer.Write((short)1);
                                icon_writer.Write((short)1);
                                icon_writer.Write((byte)width);
                                icon_writer.Write((byte)height);
                                icon_writer.Write((byte)0);
                                icon_writer.Write((byte)0);
                                icon_writer.Write((short)0);
                                icon_writer.Write((short)32);
                                icon_writer.Write((int)mem_data.Length);
                                icon_writer.Write((int)(6 + 16));
                                icon_writer.Write(mem_data.ToArray());
                                icon_writer.Flush();
                                return true;
                            }
                        }
                        return false;
                    }
                    return false;
                }
            }'
            if ((fileextension "$file") -eq ".lnk") {
                $sh = New-Object -ComObject WScript.Shell
                $target = $sh.CreateShortcut("$file").TargetPath
                if ($target) {
                    $file = $target
                }
            }
            Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.IO -ErrorAction SilentlyContinue
            $icon=[System.Drawing.Icon]::ExtractAssociatedIcon("${file}")
            [PngIconConverter]::Convert($icon.ToBitmap(),"${dest}",32,$true) | Out-Null
            $icon.Dispose()
        }
    }
}

function create_shortcut_file {
    param ([string] $name, [string] $target, [string] $targetArgs, [switch] $terminal)
    if ([string]::IsNullOrEmpty($name)) {
        errorlog "Invalid argument: -name"
        exit 1
    }
    if ([string]::IsNullOrEmpty($target)) {
        errorlog "Invalid argument: -target"
        exit 1
    }

    # Define Terminal
    if ($terminal) {
        $targetArgs = "cmd.exe /c $target $targetArgs && pause"
        $target = "wt.exe"
    }

    # Create and save
    $shell = New-Object -COM WScript.Shell
    $lnk = $shell.createShortcut("$([Environment]::GetFolderPath('Programs'))\${name}.lnk")
    $lnk.TargetPath = $target
    if (-not [string]::IsNullOrEmpty($targetArgs)) {
        $lnk.Arguments = $targetArgs
    }
    $lnk.Save()
}

function get_all_function_name {
    param([string] $script)
    [ref]$tokens      = $null
    [ref]$parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile("$PWD\$SCRIPT", $tokens, $parseErrors)
    $ast.EndBlock.Statements | Where-Object { $_.Name } | ForEach-Object { Write-Host $_.Name }
}

function define_default_system_dir {
    $result=$(read_user_keyboard "Insert all User Dirs? (y/N)")
    if ($result -eq "y") {
        $userDirs = @{}
        $isSetDirs = $false
        $result=$(select_folder_dialog "Insert DOWNLOAD (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("{374DE290-123F-4565-9164-39C4925E467B}", "$result")
        }
        $result=$(select_folder_dialog "Insert DOCUMENTS (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("Personal", "$result")
        }
        $result=$(select_folder_dialog "Insert MUSIC (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Music", "$result")
        }
        $result=$(select_folder_dialog "Insert PICTURES (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Pictures", "$result")
        }
        $result=$(select_folder_dialog "Insert VIDEOS (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Video", "$result")
        }
        foreach ($userDir in $userDirs.GetEnumerator()) {
            $isSetDirs=$true
            evaladvanced "reg add `"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`" /f /v `"$($userDir.Name)`" /t REG_SZ /d `"$($userDir.Value)`""
        }
        if ($isSetDirs){
            restartexplorer
        }
    }
}

function select_folder_dialog {
    param ([string] $message)
    log "$message"
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $null = $browser.ShowDialog()
    return $browser.SelectedPath
}

function view_markdown {
    param ([string] $file)
    & "C:\Users\nb26323\AppData\Local\Programs\Markdown Viewer\Markdown Viewer.exe" "$file"
}