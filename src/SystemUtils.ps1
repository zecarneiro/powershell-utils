# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function RestartSO {
    param(
        [string] $message
    )
    if ($message.length -le 0) {
        $message = "Will be restart PC"
    }
    $userInput = (ReadUserKeyboard -message "$message. Continue(y/N)? ")
    if ($userInput -eq "Y" -or $userInput -eq "y") {
        shutdown /r /t 0
    }
    exit 0
}

function ShutdownSO {
    param(
        [string] $message
    )
    if ($message.length -le 0) {
        $message = "Will be shutdown PC"
    }
    $userInput = (ReadUserKeyboard -message "$message. Continue(y/N)? ")
    if ($userInput -eq "Y" -or $userInput -eq "y") {
        shutdown /s /t 0
    }
    exit 0
}

function AddBootApplication {
    param ([string] $name, [string] $command, [switch] $hidden)
    $homeDir = (GetEnvironmentVariables -name 'userprofile')
    $startupDir = "$homeDir\Start Menu\Programs\Startup"
    $scriptName = "$command"
    if ($hidden) {
        $scriptName = "$OTHER_APPS_DIR\$name.vbs"
        WriteFile -f "$scriptName" -d "Dim WinScriptHost"
        WriteFile -f "$scriptName" -d "Set WinScriptHost = CreateObject(`"WScript.Shell`")" -a
        WriteFile -f "$scriptName" -d "WinScriptHost.Run `"`"`"`" & `"$command`" & `"`"`"`", 0, False" -a
        WriteFile -f "$scriptName" -d "Set WinScriptHost = Nothing" -a
    }
    $shell = new-object -com wscript.shell
    $lnk = $shell.createShortcut("$startupDir\$name.lnk")
    $lnk.TargetPath="$scriptName"
    $lnk.Save()
}

function DelBootApplication {
    param ([string] $name)
    $homeDir = (GetEnvironmentVariables -name 'userprofile')
    $startupDir = "$homeDir\Start Menu\Programs\Startup"
    if ((FileExist -file "$OTHER_APPS_DIR\${name}.vbs")) {
        FileDelete -file "$OTHER_APPS_DIR\${name}.vbs"
    }
    if ((FileExist -file "$startupDir\$name.lnk")) {
        FileDelete -file "$startupDir\$name.lnk"
    }
}

function HasInternetConnection {
    return ((Test-Connection 8.8.8.8 -Count 1 -Quiet) -or (Test-Connection 8.8.4.4 -Count 1 -Quiet) -or (Test-Connection time.google.com -Count 1 -Quiet))
}

function TestRegistryValue {
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

function TestRegistryPath {
    param ([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $path)
    try {
        Get-ItemProperty -Path $Path | Out-Null
        return $true
    } catch {
        return $false
    }
}

function IsOperatingSystemVersion {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $version
    )
    $info = (Get-ComputerInfo)
    if ($info.OsVersion -like $version) {
        return $true
    }
    return $false
}

function CreateProfileFile {
    $profilePowershell = $PROFILE.CurrentUserAllHosts
    $profilePowershellAlias = "$home\powershell-alias.ps1"
    
    # POWERSHELL
    if (!(FileExist "$profilePowershell")) {
        InfoLog "Creating Powershell Script profile to run when powrshell start: $profilePowershell"
        New-Item $profilePowershell -ItemType file -Force

        # Write aliases
        $powershellData = @"
# $AUTHOR
function show-help {
    Write-Host "This Help, show how to get help for commands. One of the options"
    Write-Host "Equivalent linux commands:"
    Write-Host "- tee"
    Write-Host "- mkdir"
    Write-Host "- cat"
    Write-Host "- ls"
    Write-Host "- sleep"
    Write-Host "- find"
    Write-Host "################"
    Write-Host ">>>> Powershell <<<<"
    Write-Host "1- Get-Help COMMAND"
    Write-Host "2- COMMAND -?"
    Write-Host ""
    Write-Host ">>>> CMD <<<<"
    Write-Host "1- help COMMAND"
    Write-Host "2- COMMAND /?"
}

function mkdir-p {
    param(
        [Parameter(Mandatory=`$true,ValueFromPipelineByPropertyName=`$true)]
        [ValidateNotNull()]
        [string] `$directory
    )
    if (! (Test-Path `$directory)) {
        mkdir `"`$directory`"
    }
}

function __GoBack { cd .. }
Set-Alias -Name ".." -Value "__GoBack"
"@
        WriteFile -f "$profilePowershellAlias" -d "$powershellData"
        WriteFile -f "$profilePowershell" -d ". `"$profilePowershellAlias`"" -a

        # Default aliases
        AddAlias -name "powershellrc-config" -command "nano.exe `"$profilePowershell`""
    }
}

function AddAlias {
    param(
        [string] $name,
        [string] $command,
        [switch] $passArgs
    )
    $profilePowershellAlias = "$home\powershell-alias.ps1"
    if ($null -ne (Select-String -Path "$profilePowershellAlias" -Pattern "function $name {")) {
        RemoveLinesFromFile -file "$profilePowershellAlias" -match "$name"
    }
    if ($passArgs) {
        WriteFile -f $profilePowershellAlias -d "function $name {$command `$args}" -a
    } else {
        WriteFile -f $profilePowershellAlias -d "function $name {$command}" -a
    }
}

function SetBinariesOnSystem {
    param([string] $binary)
    Eval -expression "sudo cp `"$binary`" C:\Windows\System32"
    Eval -expression "rm `"$binary`""
}

function AddContextMenu {
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
        InfoLog "Remove: $context"
        foreach ($type_context_element in $contextType) {
            Eval "Remove-Item -Path `"$type_context_element\$contextNoSpace`" -Recurse"
        }
        SuccessLog "Remove Done."
    } else {
        if (!(CommandExist "wt")) {
            ErrorLog "Please, install Windows Terminal"
            exit 1
        }
        if ([string]::IsNullOrEmpty($context)) {
            ErrorLog "Invalid context!!!"
            exit 1
        }
        if ([string]::IsNullOrEmpty($command)) {
            ErrorLog "Invalid command!!!"
            exit 1
        }
        AddContextMenu -context "$context"
        InfoLog "Add Context Menu: $context"
        $command = "command"
        if (![string]::IsNullOrEmpty($commandArgs)) {
            $command = "$command $commandArgs"
        }
        foreach ($type_context_element in $contextType) {
            Eval "New-Item -Path `"$type_context_element`" -Name `"$contextNoSpace`""
            Eval "New-Item -Path `"$type_context_element\$contextNoSpace`" -Name `"$command`""
            Eval "New-ItemProperty -Path `"$type_context_element\$contextNoSpace\$command`" -Name `"$contextNoSpace`" -Value `"$command`"  -PropertyType `"String`""
        }
        SuccessLog "Added Done."
    }

    # Restart Explorer
    taskkill /F /IM explorer.exe
    Start-Process explorer.exe
}