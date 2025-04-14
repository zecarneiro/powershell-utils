# Author: José M. C. Noronha

# Give user permission to run any powershell script
try {
    Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser
}
catch {
    Write-Host ""
}

# Get Script directory
$SCRIPT_UTILS_DIR = ($PSScriptRoot)

# ---------------------------------------------------------------------------- #
#                                   VARIABLE                                   #
# ---------------------------------------------------------------------------- #
$IMAGE_UTILS_DIR = "$SCRIPT_UTILS_DIR\images"

# ---------------------------------------------------------------------------- #
#                                     MAIN                                     #
# ---------------------------------------------------------------------------- #
Get-ChildItem ("${SCRIPT_UTILS_DIR}\src\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null
