# Author: José M. C. Noronha
# IMPORTANT: Save this script always with UTF-8 with BOM

$IS_INIT_PROMPT=$true

function isadmin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  return ($currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
}

# Find out if the current user identity is elevated (has admin rights)
$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
try {
  if ((isadmin)) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
  }
} catch {
  errorlog "An error occurred, when tray to check if is admin and set [ADMIN] on title of windows terminal"
}

function prompt {
  if ((isadmin)) {
    "[" + (Get-Location) + "] # "
  }
  else {
    $actualLocation = "$(Get-Location)"
    $actualLocation = $actualLocation.replace("${home}",'~')
    if ($global:IS_INIT_PROMPT) {
      Write-Host "$actualLocation" -ForegroundColor "Cyan";
      $global:IS_INIT_PROMPT=$false
    } else {
      Write-Host "`n$actualLocation" -ForegroundColor "Cyan";
    }
    if ($?) {
        Write-Host -NoNewline "→" -ForegroundColor "Green";
    } else {
        # Last command failed
        Write-Host -NoNewline "→" -ForegroundColor "Red"
    }
    " "
  }
}
