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
$TEMP_DIR="$([System.IO.Path]::GetTempPath())pwsh-utils"
$APPS_DIR="$TEMP_DIR\apps"
$APPS_BIN_DIR="$APPS_DIR\bin"
$IMAGE_UTILS_DIR = "$SCRIPT_UTILS_DIR\images"

# ---------------------------------------------------------------------------- #
#                                     MAIN                                     #
# ---------------------------------------------------------------------------- #
function __create_dirs {
    $dirs = @("$OTHER_APPS_DIR", "$CONFIG_DIR", "$APPS_BIN_DIR", "${home}\Start Menu\Programs\Startup")
    Foreach ($dir in $dirs) {
        if (!(directoryexists "$dir")) {
            New-Item -ItemType Directory -Force -Path "$dir" | Out-Null
        }
    }
}
__create_dirs
Get-ChildItem ("${SCRIPT_UTILS_DIR}\src\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null
if (!(is_valid_home_dir)) {
    show_rules_username
    throw "Create a new user account and run this script again."
}
