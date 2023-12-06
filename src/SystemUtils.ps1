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

function create_profile_file {
    $profilePowershell = $PROFILE.CurrentUserAllHosts
    $profilePowershellCustom = "powershell-profile-custom.ps1"
    $userBinDirectory = "$home\.local\bin"
    
    # POWERSHELL
    if (!(Test-Path -Path "$profilePowershell" -PathType Leaf)) {
        infolog "Creating Powershell Script profile to run when powrshell start: $profilePowershell"
        New-Item $profilePowershell -ItemType file -Force
    }
    if (!(Test-Path -Path "$userBinDirectory")) {
        New-Item -ItemType Directory -Path "$userBinDirectory"
        $pathEnv = ($env:Path -split ';')
        if (!("$userBinDirectory" -in $pathEnv)) {
            $pathEnv += "$userBinDirectory"
            [Environment]::SetEnvironmentVariable("Path", ($pathEnv -join ";"), [System.EnvironmentVariableTarget]::User)
            infolog "Please, Restart the Terminal to change take effect!"
        }
    }
    Copy-Item -Path "$SCRIPT_UTILS_DIR\others\powershell-profile\powershell-profile-custom.ps1" -Destination "$home" -PassThru | Out-Null
    if ($null -eq (Select-String -Path "$profilePowershell" -Pattern "$profilePowershellCustom")) {
        Write-Output ". `"$home\$profilePowershellCustom`"" | Tee-Object "$profilePowershell" -Append
    }
    . $profilePowershell
    # Source of those files: https://unxutils.sourceforge.net/ or on scoop: unxutils-cut
    Expand-Archive -Path "$SCRIPT_UTILS_DIR\others\bashcmd.zip" -DestinationPath "$SCRIPT_UTILS_DIR\others"
    Get-ChildItem "$SCRIPT_UTILS_DIR\others\bashcmd" | Foreach-Object {
        $fullName = ($_.FullName)
        $basename = ($_.Basename)
        $extension = ([System.IO.Path]::GetExtension("$fullName"))
        Move-Item $_.FullName -Destination "$userBinDirectory\${basename}unix${extension}" -Force
    }
    deletedirectory "$SCRIPT_UTILS_DIR\others\bashcmd"
    reloadprofile
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
        Write-Output "Dim WinScriptHost" | Tee-Object "$scriptName" | Out-Null
        Write-Output "Set WinScriptHost = CreateObject(`"WScript.Shell`")" | Tee-Object "$scriptName" -Append | Out-Null
        Write-Output "WinScriptHost.Run `"`"`"`" & `"$command`" & `"`"`"`", 0, False" | Tee-Object "$scriptName" -Append | Out-Null
        Write-Output "Set WinScriptHost = Nothing" | Tee-Object "$scriptName" -Append | Out-Null
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