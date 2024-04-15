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

function create_profile_file_prompt_cmd {
    $regeditRoot = "HKCU:"
    $profileCmdCustom = "$home\prompt-cmd-profile-custom.cmd"
    $regeditName = "AutoRun"
    $regeditPath = "\Software\Microsoft\Command Processor"
    $regeditFullPath = "${regeditRoot}${regeditPath}"
    if (!(Test-Path -Path "$profileCmdCustom" -PathType Leaf)) {
        infolog "Creating Windows Command Prompt Script profile to run when CMD start: $profileCmdCustom"
        writefile "$profileCmdCustom" "@echo off"
        writefile "$profileCmdCustom" "exit /b 0" -append
    }
    if (!(Test-Path "$regeditFullPath")) {
        New-Item -Path "$regeditRoot" -Name "$regeditPath" | Out-Null
    }
    $Key = Get-Item -LiteralPath $regeditFullPath
    $regeditValue = $Key.GetValue($regeditName, $null)
    if ($null -ne $regeditValue) {
        if (!($regeditValue.Contains("$profileCmdCustom"))) {
            $regeditValue = "`"$profileCmdCustom`" & $regeditValue"
        }
        Remove-ItemProperty -Path "$regeditFullPath" -Name "$regeditName" | Out-Null
    }
    New-ItemProperty -Path "$regeditFullPath" -Name "$regeditName" -Value "$regeditValue"  -PropertyType "String" | Out-Null
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
    reloadprofile
}

function install_bash_apps {
    $userBinDirectory = "$home\.local\bin"
    if (directoryexists "$userBinDirectory") {
        $userOption = "n"
        $currerntDir = "$pwd"
        Set-Location "$userBinDirectory"
        $allFilesInBinDir = (lf)
        Set-Location "$currerntDir"
        if (![string]::IsNullOrEmpty($allFilesInBinDir) -and $allFilesInBinDir -like "*unix.*") {
            $userOption = (Read-Host "Important bash functions already instaled. Install again(y/N)? ")
        } else {
            $userOption = "y"
        }
        if ($userOption -eq "Y" -or $userOption -eq "y") {
            # Source of those files: https://unxutils.sourceforge.net/ or on scoop: unxutils-cut
            Expand-Archive -Path "$SCRIPT_UTILS_DIR\others\bashcmd.zip" -DestinationPath "$SCRIPT_UTILS_DIR\others"
            Get-ChildItem "$SCRIPT_UTILS_DIR\others\bashcmd" | Foreach-Object {
                $fullName = ($_.FullName)
                $basename = ($_.Basename)
                $extension = ([System.IO.Path]::GetExtension("$fullName"))
                Move-Item $_.FullName -Destination "$userBinDirectory\${basename}unix${extension}" -Force
            }
            deletedirectory "$SCRIPT_UTILS_DIR\others\bashcmd"
            exitwithmsg "Please, Restart the Terminal to change take effect!"
        }
    }
}

function create_profile_file_powershell {
    $profilePowershell = $PROFILE.CurrentUserAllHosts
    $profilePowershellCustom = "$home\powershell-profile-custom.ps1"
    
    if (!(Test-Path -Path "$profilePowershellCustom" -PathType Leaf)) {
        infolog "Creating Powershel Script profile to run when powershell start: $profilePowershellCustom"
        New-Item "$profilePowershellCustom" -ItemType file -Force | Out-Null
        writefile "$profilePowershellCustom" "# BASH-LIKE TAB COMPLETION IN POWERSHELL" -append
        writefile "$profilePowershellCustom" "Set-PSReadlineKeyHandler -Key Tab -Function Complete" -append
        writefile "$profilePowershellCustom" "Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward" -append
        writefile "$profilePowershellCustom" "Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward" -append
        writefile "$profilePowershellCustom" "" -append
    }
    # POWERSHELL
    if (!(Test-Path -Path "$profilePowershell" -PathType Leaf)) {
        infolog "Creating Powershell Script profile to run when powrshell start: $profilePowershell"
        New-Item $profilePowershell -ItemType file -Force
    }
    if (!(filecontain "$profilePowershell" "$profilePowershellCustom")) {
        writefile "$profilePowershell" ". '$profilePowershellCustom'" -append
    }
}

function create_profile_file {
    $profilesShellDir = "${OTHER_APPS_DIR}\profile-shell"
    $profilePowershellCustom = "$home\powershell-profile-custom.ps1"
    $profileCmdCustom = "$home\prompt-cmd-profile-custom.cmd"
    create_profile_file_powershell
    create_profile_file_prompt_cmd
    Copy-Item -Path "$SCRIPT_UTILS_DIR\others\profile-shell" -Destination "$OTHER_APPS_DIR" -Recurse -Force | Out-Null

    # Add powershell profiles
    Get-ChildItem -Path "$profilesShellDir" -Filter *.ps1 -Recurse -File | ForEach-Object {
        $fullName = $_.FullName
        $dataToInsert = ". '$fullName'"
        if (!(filecontain "$profilePowershellCustom" "$dataToInsert")) {
            writefile "$profilePowershellCustom" "$dataToInsert" -append
        }
    }

    # Add prompt cmd profiles
    delfilelines "$profileCmdCustom" "exit /b 0"
    Get-ChildItem -Path "$profilesShellDir" -Filter *.cmd -Recurse -File | ForEach-Object {
        $fullName = $_.FullName
        $dataToInsert = "CALL ```"$fullName```""
        if (!(filecontain "$profileCmdCustom" "CALL `"$fullName`"")) {
            writefile "$profileCmdCustom" "$dataToInsert" -append
        }
    }
    writefile "$profileCmdCustom" "exit /b 0" -append
    exitwithmsg "Please, Restart the Terminal to change take effect!"
}

function set_binaries_on_system {
    param([string] $binary)
    evaladvanced "sudo cp `"$binary`" C:\Windows\System32"
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

function add_boot_application {
    param ([string] $name, [string] $command, [string] $commandArgs, [switch] $hidden)
    $startupDir = "$home\Start Menu\Programs\Startup"
    $scriptName = "$command"
    if ($hidden) {
        $scriptName = "$OTHER_APPS_DIR\$name.vbs"
        writefile "$scriptName" "Dim WinScriptHost"
        writefile "$scriptName" "Set WinScriptHost = CreateObject(```"WScript.Shell```")" -append
        writefile "$scriptName" "WinScriptHost.Run ```"```"```"```" & ```"$command```" & ```"```"```"```", 0, False" -append
        writefile "$scriptName" "Set WinScriptHost = Nothing" -append
    }
    create_shortcut_file_generic -name "$startupDir\$name.lnk" -target "$command" -targetArgs "$commandArgs"
}

function del_boot_application {
    param ([string] $name)
    $startupDir = "$home\Start Menu\Programs\Startup"
    if ((fileexists "$OTHER_APPS_DIR\${name}.vbs")) {
        deletefile "$OTHER_APPS_DIR\${name}.vbs"
    }
    if ((fileexists "$startupDir\$name.lnk")) {
        deletefile "$startupDir\$name.lnk"
    }
}