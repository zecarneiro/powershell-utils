# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function read_user_keyboard {
    param([string] $message)
    $line = Read-Host "$message"
    return $line;
}


function confirm {
    param([string] $message, [bool] $isYesDefault)
    if ($isYesDefault) {
        $message = "${message}? [Y/n]"
    } else {
        $message = "${message}? [y/N]"
    }
    $res = (read_user_keyboard "$message")
    if (($isYesDefault -and [string]::IsNullOrEmpty($res)) -or $res -eq "y" -or $res -eq "Y") {
        return $true
    }
    return $false
}
  
function wait_for_any_key_pressed {
    param ([string] $message)
    Write-Host -NoNewLine "$message";
    ($Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown"))
    log ""
}