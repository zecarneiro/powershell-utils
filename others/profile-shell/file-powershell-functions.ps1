# Author: José M. C. Noronha

function fileexists($file) {
    if (!([string]::IsNullOrEmpty($file)) -and (Test-Path -Path "$file" -PathType Leaf)) {
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
    try {
        if ($append -and (fileexists "$file")) {
        [System.IO.File]::AppendAllLines([string]"$file", [string[]]$content)
        } else {
            $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
            [System.IO.File]::WriteAllLines("$file", $content, $Utf8NoBomEncoding)
        }
    } catch {
        errorlog "Get error on write to file: $file with func writefile"
    }
    
}
function writefile-simple {
    param(
        [string] $file,
        [string] $content,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "writefile-simple FILE CONTENT"
        return
    }
    Out-File -FilePath "$file" -Value "$content"
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
        Get-Content $file | findstr /V "$match" | Out-File $tempfile -Encoding Ascii
        Move-Item "$tempfile" -Destination "$file" -Force
    }
}
function deletefile($file) {
    if ((fileexists "$file")) {
        infolog "Deleting: $file"
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
function openmarkdown {
    param ([string] $file)
    if ((fileexists "$file")) {
        if ((commandexists "ghostwriter")) {
            & ghostwriter "$file"
        } else {
            Get-Content "$file"
        }
    } else {
        errorlog "Invalid given file: $file"
    }
}
function openimage {
    param ([string] $file)
    if ((fileexists "$file")) {
        Start-Process "$file"
    }
}
