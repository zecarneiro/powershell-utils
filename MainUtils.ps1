# Author: José M. C. Noronha
param(
    [string] $typeOperation
)

# Give user permission to run any powershell script
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
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
$IS_DEPENDENCIES_PROCESSED_DONE = $false

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

function install_dependencies {
    __create_dirs
    . "${SCRIPT_UTILS_DIR}\src\PackageUtils.ps1"
    install_scoop
    install_base_scoop_package
    # Docs
    titlelog "Integrate 7zip on context menu"
    log "Step 1: Open 7-Zip File Manager(As Admin) by typing 7-Zip in Start menu or Start screen and then pressing Enter key."
    log "Step 2: Next, navigate to Tools menu and then click Options to open Options dialog."
    log "Step 3: Here, under 7-Zip tab, make sure that Integrate 7-Zip to shell context menu option is selected. If not, please select the option and then click Apply button. You might need to reboot your PC or restart Windows Explorer to see 7-Zip in the context menu."
    pause

    $res = Read-Host "For Windows 11 only. Do you want to enable sudo? [y/N]"
    if ("$res" -eq "y" -or "$res" -eq "Y") {
        powershell -Command "Start-Process -Wait PowerShell -Verb RunAs -ArgumentList 'sudo.exe config --enable enable'"
    }
    infolog "Please, restart terminal"
}

if ("$typeOperation" -eq "IMPORT_ALL_LIBS") {
    Get-ChildItem ("${SCRIPT_UTILS_DIR}\src\*.ps1") | ForEach-Object { . $_.FullName } | Out-Null
    if (!(is_valid_home_dir)) {
        show_rules_username
        throw "Create a new user account and run this script again."
    }
}
