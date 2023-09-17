# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
# Source code: https://gist.github.com/dkarzon/a7a7e98a42dde86fca9e
function ResizeImage {
    param(
        [string]$src,
        [string]$dest,
        [int]$width,
        [int]$height,
        [int]$scale
    )

    if ((FileExist -file "$src")) {
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
    } else {
        ErrorLog "File not exist: ${file}"
    }
}

function IconExtractor {
    param (
        [string] $file,
        [string] $dest,
        [switch] $display
    )
    if ((FileExist -file "$file") -and (((FileExtension -file "$file") -eq ".lnk") -or ((FileExtension -file "$file") -eq ".exe"))) {
        if (-not [string]::IsNullOrEmpty("${dest}") -and ((FileExtension -file "$dest") -eq ".ico") -and !(FileExist -file "${dest}")) {
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
            if ((FileExtension -file "$file") -eq ".lnk") {
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
    } else {
        ErrorLog "File not exist: ${file}"
    }
}

function CreateShortcutFile {
    param ([string] $name, [string] $target, [string] $targetArgs, [switch] $terminal)
    if ([string]::IsNullOrEmpty($name)) {
        ErrorLog "Invalid argument: -name"
        exit 1
    }
    if ([string]::IsNullOrEmpty($target)) {
        ErrorLog "Invalid argument: -target"
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

function Dirname {
    param (
        [String] $file
    )
    return ([System.IO.Path]::GetDirectoryName($file))
}

function Basename {
    param (
        [string] $file
    )
    return ([io.fileinfo]$file).basename
}

function FilenameWithoutExtension {
    param ([string] $file)
    return [System.IO.Path]::GetFileNameWithoutExtension("$file")
}

function FileExtension {
    param ([string] $file)
    return [System.IO.Path]::GetExtension("$file")
}

function CopyFile {
    param (
        [string]$src,
        [string]$dest,
        [switch]$force
    )
    if ((FileExist -file "$src")) {
        if ($force) {
            [System.IO.File]::Copy($src, $dest, $true);
        } else {
            [System.IO.File]::Copy($src, $dest, $false);
        }
    } else {
        ErrorLog "File not exist: ${file}"
    }
    
}

function GetWorkingDir {
    return (Get-Location | Foreach-Object { $_.Path })
}

function IsDirectory {
    param (
        [string] $file
    )
    if ((FileExist -file "$file")) {
        return (Get-Item "$file" -Force) -is [System.IO.DirectoryInfo]
    }
    return $FALSE
}
  
function FileDelete {
    param (
        [string] $file,
        [bool] $verbose = $true
    )
    if ((FileExist -file "$file")) {
        Eval -expression "Remove-Item `"$file`" -Recurse -Force" -verbose $verbose
    }
    else {
        WarnningLog "File not exist: ${file}"
    }
}

function CreateDirectory {
    param ([string] $file, [switch] $display)
    if (!(FileExist -file "$file")) {
        if ($display) {
            Eval -expression "New-Item -ItemType Directory -Force -Path `"$file`""
        } else {
            Eval -expression "New-Item -ItemType Directory -Force -Path `"$file`" | Out-Null"
        }
    }
}

function WriteFile {
    param(
        [string] $f,
        [string] $d = "",
        [switch] $a
    )
    $file = $f; $append = $a; $data = $d
    if (!$append) {
        FileDelete -file "$file"
    }
    if (!(FileExist -file "$file")) {
        "$data" | Add-Content -Path "$file"
    } else {
        Add-Content -Path "$file" -Value "$data"
    }
}

function FileExist {
    param(
        [string] $file
    )
    if (((Test-Path -Path "$file")) -or (Test-Path -Path "$file" -PathType Leaf)) {
        return $TRUE
    }
    return $FALSE
}

function Download {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$URL,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$File 
    )
    Begin {
        function Show-Progress {
            param (
                # Enter total value
                [Parameter(Mandatory)]
                [Single]$TotalValue,
        
                # Enter current value
                [Parameter(Mandatory)]
                [Single]$CurrentValue,
        
                # Enter custom progresstext
                [Parameter(Mandatory)]
                [string]$ProgressText,
        
                # Enter value suffix
                [Parameter()]
                [string]$ValueSuffix,
        
                # Enter bar lengh suffix
                [Parameter()]
                [int]$BarSize = 40,

                # show complete bar
                [Parameter()]
                [switch]$Complete
            )
            
            # calc %
            $percent = $CurrentValue / $TotalValue
            $percentComplete = $percent * 100
            if ($ValueSuffix) {
                $ValueSuffix = " $ValueSuffix" # add space in front
            }
            if ($psISE) {
                Write-Progress "$ProgressText $CurrentValue$ValueSuffix of $TotalValue$ValueSuffix" -id 0 -percentComplete $percentComplete            
            }
            else {
                # build progressbar with string function
                $curBarSize = $BarSize * $percent
                $progbar = ""
                $progbar = $progbar.PadRight($curBarSize, [char]9608)
                $progbar = $progbar.PadRight($BarSize, [char]9617)
        
                if (!$Complete.IsPresent) {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($CurrentValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"
                }
                else {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($TotalValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"                    
                }                
            }   
        }
    }
    Process {
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'

            if (!(HasInternetConnection)) {
                throw "No Internet connection available"
            }
        
            # invoke request
            $request = [System.Net.HttpWebRequest]::Create($URL)
            $response = $request.GetResponse()
  
            if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
                throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
            }
  
            if ($File -match '^\.\\') {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") ($File -Split '^\.')[1]
            }
            
            if ($File -and !(Split-Path $File)) {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") $File
            }

            if ($File) {
                $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
                if (!(Test-Path($fileDirectory))) {
                    [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
                }
            }

            [long]$fullSize = $response.ContentLength
            $fullSizeMB = $fullSize / 1024 / 1024
  
            # define buffer
            [byte[]]$buffer = new-object byte[] 1048576
            [long]$total = [long]$count = 0
  
            # create reader / writer
            $reader = $response.GetResponseStream()
            $writer = new-object System.IO.FileStream $File, "Create"
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($File)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($File)" -ValueSuffix "MB" -Complete
                    $finalBarCount++
                }
            } while ($count -gt 0)
            Write-Host -NoNewLine "`n"
        }
        catch {
            $ExeptionMsg = $_.Exception.Message
            ErrorLog "$ExeptionMsg"
        }
  
        finally {
            # cleanup
            if ($reader) { $reader.Close() }
            if ($writer) { $writer.Flush(); $writer.Close() }
        
            $ErrorActionPreference = $storeEAP
            [GC]::Collect()
        }    
    }
}

function GetAllFuncionName {
    param([string] $script)
    [ref]$tokens      = $null
    [ref]$parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile("$PWD\$SCRIPT", $tokens, $parseErrors)
    $ast.EndBlock.Statements | Where-Object { $_.Name } | ForEach-Object { Write-Host $_.Name }
}

function RemoveLinesFromFile {
    param (
        [string] $file,
        [string] $match
    )
    $file_tmp = $file + "tmp"
    Get-Content $file | Where-Object {$_ -notmatch $match} | Set-Content -Path $file_tmp
    Move-Item "$file_tmp" -Destination "$file" -Force
}

function DefineDefaultSystemDir {
    $result=$(ReadUserKeyboard "Insert all User Dirs? (y/N)")
    if ($result -eq "y") {
        $userDirs = @{}
        $isSetDirs = $false
        $result=$(SelectFolderDialog "Insert DOWNLOAD (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("{374DE290-123F-4565-9164-39C4925E467B}", "$result")
        }
        $result=$(SelectFolderDialog "Insert DOCUMENTS (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("Personal", "$result")
        }
        $result=$(SelectFolderDialog "Insert MUSIC (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Music", "$result")
        }
        $result=$(SelectFolderDialog "Insert PICTURES (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Pictures", "$result")
        }
        $result=$(SelectFolderDialog "Insert VIDEOS (Or cancel)")
        if (! [string]::IsNullOrEmpty($result)) {
            $userDirs.Add("My Video", "$result")
        }
        foreach ($userDir in $userDirs.GetEnumerator()) {
            $isSetDirs=$true
            Eval -expression "reg add `"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`" /f /v `"$($userDir.Name)`" /t REG_SZ /d `"$($userDir.Value)`""
        }
        if ($isSetDirs){
            taskkill /f /IM explorer.exe
            start explorer.exe
        }
    }
}

function SelectFolderDialog {
    param ([string] $message)
    LogLog "$message"
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $null = $browser.ShowDialog()
    return $browser.SelectedPath
}

function ViewMarkdown {
    param ([string] $file)
    & "C:\Users\nb26323\AppData\Local\Programs\Markdown Viewer\Markdown Viewer.exe" "$file"
}