# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #  
function IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    return ($currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
}
  
function Cut {
    param(
        [string] $data,
        [string] $delimiter,
        [ValidateSet("L", "R", IgnoreCase = $false)]
        [string] $direction
    )
    if ($data.Length -gt 0) {
        if ($direction -eq "R") {
            $pos = ($data.IndexOf($delimiter) + $delimiter.Length)
            return $data.Substring($pos)
        }
        elseif ($direction -eq "L") {
            return $data.Substring(0, $data.IndexOf($delimiter))
        }
        return $data
    }
}
  
function Grep {
    param (
        [string] $f,
        [string] $r
    )
    $file = $f; $regex = $r
    Select-String -Path $file -Pattern $regex
}
  
function Sed {
    param(
        [string] $file,
        [string] $regex,
        [string] $replace,
        [switch] $inPlace
    )
    if ($data.Length -eq 0) {
        $data = (Get-Content $file)
    }
    $newData = ($data -replace $regex, $replace)
    if ($inPlace) {
        $newData | Set-Content $file
    }
    else {
        return $newData
    }
}
  
function Trim {
    param (
        [string] $d,
        [string] $c = "`n "
    )
    $data = $d; $characters = $c
    if ($data.Length -gt 0) {
        $data = $data.Trim($characters)
    }
    return $data
}

function CreateZip {
    param (
        [string] $file
    )
    Compress-Archive -Path "$file" -DestinationPath "$($file).zip" -Force
}

function OpenURL {
    param ([string] $url)
    if ([string]::IsNullOrEmpty($url)) {
        ErrorLog "Invalid URL"
    } else {
        Start-Process "$url"
    }
}