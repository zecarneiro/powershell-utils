# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function test_registry_value {
    param (
        [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $path,
        [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $value
    )
    try {
        Get-ItemPropertyValue "$path" "$value" -ErrorAction Stop
    } catch {
        return $false
    }
    return $true
}

function test_registry_path {
    param ([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $path)
    try {
        Get-ItemProperty -Path $Path | Out-Null
        return $true
    } catch {
        return $false
    }
}

function set_user_bin_dir {
    $userBinDirectory = "$home\.local\bin"
    $pathKey = "Path"
    if (!(Test-Path -Path "$userBinDirectory")) {
        New-Item -ItemType Directory -Path "$userBinDirectory" | Out-Null
    }
    $pathEnvArr = ([Environment]::GetEnvironmentVariable($pathKey, [System.EnvironmentVariableTarget]::User) -split ';')
    if (!("$userBinDirectory" -in $pathEnvArr)) {
        $pathEnvArr += "$userBinDirectory"
        [Environment]::SetEnvironmentVariable($pathKey, ($pathEnvArr -join ";"), [System.EnvironmentVariableTarget]::User)
        infolog "Please, Restart the Terminal to change take effect!"
    }
    . reloadprofile
}

function create_profile_file_powershell {
    $profilePowershell = $PROFILE.CurrentUserAllHosts
    $profilePowershellCustom = "${OTHER_APPS_DIR}\powershell-profile-custom.ps1"
    $bashTasbCompletionArr = @(
        "# BASH-LIKE TAB COMPLETION IN POWERSHELL"
        "Set-PSReadlineKeyHandler -Key Tab -Function Complete"
        "Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward"
        "Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward"
    )

    # POWERSHELL
    if (!(Test-Path -Path "$profilePowershell" -PathType Leaf)) {
        infolog "Creating Powershell Script profile to run when powrshell start: $profilePowershell"
        New-Item "$profilePowershell" -ItemType file -Force
    }
    
    if (!(Test-Path -Path "$profilePowershellCustom" -PathType Leaf)) {
        infolog "Creating Powershel Script profile to run when powershell start: $profilePowershellCustom"
        New-Item "$profilePowershellCustom" -ItemType file -Force | Out-Null
    }
    foreach ($bashTasbCompletion in $bashTasbCompletionArr) {
        if (!(filecontain "$profilePowershellCustom" "$bashTasbCompletion")) {
            writefile "$profilePowershellCustom" "$bashTasbCompletion" -append
        }
    }
    if (!(filecontain "$profilePowershell" "$profilePowershellCustom")) {
        writefile "$profilePowershell" ". '$profilePowershellCustom'" -append
    }
}

function create_profile_file {
    $profilesShellDir = "${OTHER_APPS_DIR}\profile-shell"
    $profilePowershellCustom = "${OTHER_APPS_DIR}\powershell-profile-custom.ps1"
    create_profile_file_powershell
    Copy-Item -Path "$SCRIPT_UTILS_DIR\others\profile-shell" -Destination "$OTHER_APPS_DIR" -Recurse -Force | Out-Null

    # Add powershell profiles
    Get-ChildItem -Path "$profilesShellDir" -Filter *.ps1 -Recurse -File | ForEach-Object {
        $fullName = $_.FullName
        $dataToInsert = ". '$fullName'"
        if (!(filecontain "$profilePowershellCustom" "$dataToInsert")) {
            writefile "$profilePowershellCustom" "$dataToInsert" -append
        }
    }
    infolog "Please, Restart the Terminal to change take effect!"
}

function set_binaries_on_system {
    param([string] $binary)
    evaladvanced "sudopwsh cp `"$binary`" C:\Windows\System32"
    evaladvanced "rm `"$binary`""
}

function add_context_menu {
    param (
        [string] $context,
        [string] $command,
        [string] $commandArgs,
        [switch] $delete
    )
    $regeditCommand = "HKCR:"
    $contextType = @(
        "$regeditCommand\Directory\Background\shell"        # SELECTED_EMPTY
        "$regeditCommand\Directory\shell"                   # SELECTED_DIRECTORY
        "$regeditCommand\Drive\shell"                       # SELECTED_DRIVE
        "$regeditCommand\LibraryFolder\Background\shell"    # SELECTED_LIBRARY_FOLDER
    )
    $contextNoSpace = $context -replace " ",""
    if ($delete) {
        infolog "Remove: $context"
        foreach ($type_context_element in $contextType) {
            evaladvanced "Remove-Item -Path `"$type_context_element\$contextNoSpace`" -Recurse"
        }
        oklog "Remove Done."
    } else {
        if (!(commandexists "wt")) {
            errorog "Please, install Windows Terminal"
            exit 1
        }
        if ([string]::IsNullOrEmpty($context)) {
            errorog "Invalid context!!!"
            exit 1
        }
        if ([string]::IsNullOrEmpty($command)) {
            errorog "Invalid command!!!"
            exit 1
        }
        add_context_menu -context "$context"
        infolog "Add Context Menu: $context"
        $command = "command"
        if (![string]::IsNullOrEmpty($commandArgs)) {
            $command = "$command $commandArgs"
        }
        foreach ($type_context_element in $contextType) {
            evaladvanced "New-Item -Path `"$type_context_element`" -Name `"$contextNoSpace`""
            evaladvanced "New-Item -Path `"$type_context_element\$contextNoSpace`" -Name `"$command`""
            evaladvanced "New-ItemProperty -Path `"$type_context_element\$contextNoSpace\$command`" -Name `"$contextNoSpace`" -Value `"$command`"  -PropertyType `"String`""
        }
        oklog "Added Done."
    }
    restartexplorer
}

function create_script_to_run_cmd_hidden {
    param ([string] $name, [string] $command)
    $scriptName = "$name.vbs"
    writefile "$scriptName" "Dim WinScriptHost"
    writefile "$scriptName" "Set WinScriptHost = CreateObject(`"WScript.Shell`")" -append
    writefile "$scriptName" "WinScriptHost.Run `"`"`"`" & `"$command`" & `"`"`"`", 0, False" -append
    writefile "$scriptName" "Set WinScriptHost = Nothing" -append
}

function add_boot_application {
    param ([string] $name, [string] $command, [string] $commandArgs, [switch] $hidden)
    $startupDir = "$home\Start Menu\Programs\Startup"
    if ($hidden) {
        create_script_to_run_cmd_hidden "$OTHER_APPS_DIR\$name-autostart" "$command"
        $command = "$OTHER_APPS_DIR\$name-autostart.vbs"
    }
    create_shortcut_file_generic -name "$startupDir\$name.lnk" -target "$command" -targetArgs "$commandArgs"
}

function del_boot_application {
    param ([string] $name)
    $startupDir = "$home\Start Menu\Programs\Startup"
    if ((fileexists "$OTHER_APPS_DIR\${name}-autostart.vbs")) {
        deletefile "$OTHER_APPS_DIR\${name}-autostart.vbs"
    }
    if ((fileexists "$startupDir\$name.lnk")) {
        deletefile "$startupDir\$name.lnk"
    }
}
