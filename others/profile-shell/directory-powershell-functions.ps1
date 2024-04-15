# Author: José M. C. Noronha

function gouserotherapps {
    $directory = "$home\otherapps"
    if (!(directoryexists "$directory")) {
        mkdir -p "$directory"
    }
    Set-Location "$directory"
}
function gouserconfig {
    $directory = "$home\.config"
    if (!(directoryexists "$directory")) {
        mkdir -p "$directory"
    }
    Set-Location "$directory"
}
function directoryexists($directory) {
    if (Test-Path -Path "$directory") {
        RETURN $true
    }
    RETURN $false
}
function deletedirectory($directory) {
    if ((directoryexists "$directory")) {
        Remove-Item "$directory" -Recurse -Force
    }
}
function deleteemptydirs {
    Get-ChildItem -Path "$pwd" -Recurse -Directory | Where-Object { @(Get-ChildItem $_.FullName).Length -eq 0} | Remove-Item -Force -Verbose
}
function gohome {
    Set-Location "$home"
}
function cd.. {
    Set-Location ..
}
Set-Alias -Name ".." -Value cd..
function ldir {
    Get-ChildItem -Path "$pwd" -Directory | ForEach-Object {$_.BaseName}
}
function countdirs {
    (Get-ChildItem -Path "$pwd" -recurse | where-object { $_.PSIsContainer }).Count    
}
function dirname($file) {
    Write-Output ([System.IO.Path]::GetDirectoryName($file))
}
