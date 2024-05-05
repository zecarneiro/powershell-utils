# Author: José M. C. Noronha

# Get Script directory
$SCRIPT_UTILS_DIR = ($PSScriptRoot)

# ---------------------------------------------------------------------------- #
#                                    IMPORTS                                   #
# ---------------------------------------------------------------------------- #
Get-ChildItem ("${SCRIPT_UTILS_DIR}\others\profile-shell\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null
Get-ChildItem ("${SCRIPT_UTILS_DIR}\src\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null

# ---------------------------------------------------------------------------- #
#                                   VARIABLE                                   #
# ---------------------------------------------------------------------------- #
$TEMP_DIR=$(mktemp -d)
$CONFIG_DIR = "$home\.config"
$OTHER_APPS_DIR = "$home\.otherapps"
$APPS_DIR="$TEMP_DIR\apps"
$APPS_BIN_DIR="$APPS_DIR\bin"
$IMAGE_UTILS_DIR = "$SCRIPT_UTILS_DIR\images"

# ---------------------------------------------------------------------------- #
#                                  OPERATIONS                                  #
# ---------------------------------------------------------------------------- #
function create_dirs {
    $dirs = @("$OTHER_APPS_DIR", "$CONFIG_DIR", "$APPS_BIN_DIR")
    Foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Force -Path "$dir" | Out-Null
    }
}

# ---------------------------------------------------------------------------- #
#                                     MAIN                                     #
# ---------------------------------------------------------------------------- #
create_dirs
