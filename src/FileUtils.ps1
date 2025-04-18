# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function get_working_dir {
    return (Get-Location | Foreach-Object { $_.Path })
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

function create_shortcut_file {
    param ([string] $name, [string] $target, [string] $targetArgs, [bool] $terminal, [string] $icon)
    create_shortcut_file_generic -name "$([Environment]::GetFolderPath('Programs'))\${name}.lnk" -target "$target" -targetArgs "$targetArgs" -terminal $terminal -icon "$icon"
}

function del_shortcut_file {
    param ([string] $name)
    $name = "$([Environment]::GetFolderPath('Programs'))\${name}.lnk"
    if (fileexists "$name") {
        evaladvanced "Remove-Item -Path `"$name`" -Force"
    }
}

function create_shortcut_file_generic {
    param ([string] $name, [string] $target, [string] $targetArgs, [bool] $terminal, [string] $icon)
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
    $lnk = $shell.createShortcut("$name")
    if (!([string]::IsNullOrEmpty($icon))) {
        $lnk.IconLocation = "$icon"
    }
    $lnk.TargetPath = $target
    if (-not [string]::IsNullOrEmpty($targetArgs)) {
        $lnk.Arguments = $targetArgs
    }
    $lnk.Save()
}
