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
