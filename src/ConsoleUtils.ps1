# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function read_user_keyboard {
    param([string] $message)
    $line = Read-Host "$message"
    return $line;
}
  
function wait_for_any_key_pressed {
    param ([string] $message)
    Write-Host -NoNewLine "$message";
    ($Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown"))
    log ""
}