# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   VARIABLE                                   #
# ---------------------------------------------------------------------------- #
$AUTHOR = "Author: José M. C. Noronha"
$SCRIPT_UTILS_DIR = ($PSScriptRoot)
$HOME_DIR = [System.Environment]::GetEnvironmentVariable("userprofile")
$OTHER_APPS_DIR = "$HOME_DIR\otherapps"
$CONFIG_DIR = "$HOME_DIR\.config"
$USER_DOCUMENTS_DIR = [Environment]::GetFolderPath("MyDocuments")
$APPS_DIR="$SCRIPT_UTILS_DIR\..\apps"
$APPS_BIN_DIR="$APPS_DIR\bin"
$APPS_GO_DIR="$APPS_DIR\go"
$APPS_BASH_DIR="$APPS_DIR\bash"
$APPS_JAVASCRIPT_DIR="$APPS_DIR/javascript"
$IMAGE_UTILS_DIR = "$SCRIPT_UTILS_DIR\images"

# ---------------------------------------------------------------------------- #
#                                    IMPORTS                                   #
# ---------------------------------------------------------------------------- #
Get-ChildItem ($SCRIPT_UTILS_DIR + "\src\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null

# ---------------------------------------------------------------------------- #
#                                  OPERATIONS                                  #
# ---------------------------------------------------------------------------- #
function CreateDirs {
    $dirs = @("$OTHER_APPS_DIR", "$CONFIG_DIR", "$APPS_BIN_DIR")
    Foreach ($dir in $dirs) {
        CreateDirectory -file "$dir"
    }
}

# ---------------------------------------------------------------------------- #
#                                     MAIN                                     #
# ---------------------------------------------------------------------------- #
CreateDirs