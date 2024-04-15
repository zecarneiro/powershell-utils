# Author: José M. C. Noronha

function fileexists($file) {
    if (Test-Path -Path "$file" -PathType Leaf) {
        RETURN $true
    }
    RETURN $false
}
function fileextension($file) {
    Write-Output ([System.IO.Path]::GetExtension("$file"))
}
function filename($file) {
    Write-Output ([System.IO.Path]::GetFileNameWithoutExtension("$file"))
}
function writefile {
    param(
        [string] $file,
        [string] $content,
        [switch] $append,
        [string] $enconding,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "writefile FILE CONTENT [ |APPEND] [ |ECONDING]"
        return
    }
    $command_to_run = "`"$content`" | Out-File $file"
    if ($append) {
        $command_to_run = "$command_to_run -Append"
    }
    if ([string]::IsNullOrEmpty($enconding)) {
        if ((fileextension("$file") -eq ".cmd") -or (fileextension("$file") -eq ".bat")) {
            $enconding = "-Encoding Ascii"
        } else {
            $enconding = ""
        }
    }
    else {
        $enconding = "-Encoding $enconding"
    }
    $command_to_run = "$command_to_run $enconding | Out-Null"
    Invoke-Expression $command_to_run
}
function delfilelines {
    param (
        [string] $file,
        [string] $match,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "delfilelines FILE MATCH"
        return
    }
    if ((filecontain "$file" "$match")) {
        $tempfile = $file + ".tmp"
        Get-Content $file | grep /V "$match" | Out-File $tempfile -Encoding Ascii
        Move-Item "$tempfile" -Destination "$file" -Force
    }
}
function deletefile($file) {
    if ((fileexists "$file")) {
        Remove-Item "$file" -Recurse -Force
    }
}
function countfiles {
    (Get-ChildItem -File | Measure-Object).Count
}
function findfile($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
function movefilestoparent {
    Get-ChildItem -Path "$pwd" -Recurse -File | Move-Item -Destination "$pwd" -Verbose
}
function lf {
    Get-ChildItem -Path "$pwd" -File | ForEach-Object { $_.FullName }
}
function filecontain {
    param (
        [string] $file,
        [string] $match,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "filecontain FILE MATCH"
        return
    }
    $result = $false
    if ((fileexists "$file")) {
        $contents = (Get-Content "$file")
        foreach ($content in $contents) {
            if ($content.Contains("$match")) {
                $result = $true
                break
            }
        }
    }
    RETURN $result
}
function basename($file) {
    [System.IO.Path]::GetFileName($file)
}
function touch($file) {
    "" | Out-File $file -Encoding ASCII | Out-Null
}