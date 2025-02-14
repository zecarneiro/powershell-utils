# Author: José M. C. Noronha
# Some code has source: https://github.com/ChrisTitusTech/powershell-profile

function reboot {
  $userInput = (Read-Host "Will be reboot PC. Continue(y/N)?")
  if ($userInput -eq "Y" -or $userInput -eq "y") {
    evaladvanced "$(which "shutdown") /r /t 0"
  }
}
function shutdown {
  $userInput = (Read-Host "Will be shutdown PC. Continue(y/N)?")
  if ($userInput -eq "Y" -or $userInput -eq "y") {
    evaladvanced "$(which "shutdown") /s /t 0"
  }
}
function evaladvanced($expression, $onlyRun) {
  if (!$onlyRun) {
    promptlog "$expression"
  }
  Invoke-Expression $expression
}
function commandexists($command) {
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  try { if (Get-Command $command) { RETURN $true } }
  Catch { RETURN $false }
  Finally { $ErrorActionPreference = $oldPreference }
}
function addalias {
  param(
    [string] $name,
    [string] $command,
    [switch] $passArgs,
    [switch] $isNotFunction,
    [Alias("h")]
    [switch] $help
  )
  if ($help) {
    log "addalias NAME COMMAND [|-passargs] [|-isNotFunction]"
    return
  }
  # Create powershell alias file
  $profilePowershellAlias = "$home\.otherapps\powershell-alias.ps1"
  if (!(fileexists "$profilePowershellAlias")) {
    $profilePowershellCustom = "$home\.otherapps\powershell-profile-custom.ps1"
    if (!(filecontain "$profilePowershellCustom" "$profilePowershellAlias")) {
      writefile "$profilePowershellCustom" ". '$profilePowershellAlias'" -append
    }
  }
  # Add alias
  if ($isNotFunction) {
    if ((filecontain "$profilePowershellAlias" "Set-Alias -Name '$name'")) {
      delfilelines -file "$profilePowershellAlias" -match "Set-Alias -Name '$name'"
    }
    writefile "$profilePowershellAlias" "Set-Alias -Name '$name' -Value $command" -append
  } else {
    if ((filecontain "$profilePowershellAlias" "function $name {")) {
      delfilelines -file "$profilePowershellAlias" -match "$name"
    }
    if ($passArgs) {
      writefile "$profilePowershellAlias" "function $name {$command `$args}" -append
    } else {
      writefile "$profilePowershellAlias" "function $name {$command}" -append
    }
  }
}
function editalias {
  nano.exe "$home\.otherapps\powershell-alias.ps1"
}
function editprofile {
  nano.exe "${profile.CurrentUserAllHosts}"
}
function editcustomprofile {
  nano.exe "$home\.otherapps\powershell-profile-custom.ps1"
}
<#
.DESCRIPTION

Relad shell without restart terminal or logout

.EXAMPLE

PS> . reloadprofile
#>
function reloadprofile {
  @(
    $Profile.AllUsersAllHosts,
    $Profile.AllUsersCurrentHost,
    $Profile.CurrentUserAllHosts,
    $Profile.CurrentUserCurrentHost
  ) | ForEach-Object {
    if (Test-Path -Path "$_" -PathType Leaf) {
      infolog "Running $_"
      . $_
    }
  }
}
function ver {
  systeminfo | findstr /B /C:"OS Name" /B /C:"OS Version"
}
function trash($file) {
  $shell = new-object -comobject "Shell.Application"
  if ((fileexists "$file")) {
    $file = (Resolve-Path -LiteralPath "$file")
    $shell.Namespace(0).ParseName("$file").InvokeVerb("delete")
  } elseif ((directoryexists "$file")) {
    $file = (Resolve-Path -Path "$file")
    $shell.Namespace(0).ParseName("$file").InvokeVerb("delete")
  }
}

function uptime {
  #Windows Powershell only
  if ($PSVersionTable.PSVersion.Major -eq 5 ) {
    Get-WmiObject win32_operatingsystem | Select-Object @{EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } | Format-Table -HideTableHeaders
  } else {
    net statistics workstation | Select-String "since" | foreach-object { $_.ToString().Replace('Statistics since ', '') }
  }
}
function ix($file) {
  curl.exe -F "f:1=@$file" ix.io
}
function export($expression) {
  if ([string]::IsNullOrEmpty($expression)) {
    Get-ChildItem env:*
  }
  else {
    if (!$expression.Contains("=")) {
      Write-Output "Environment variable $expression not defined"
    }
    else {
      $expressionArr = $expression.Split("=")
      $name = $expressionArr[0]
      $value = ""
      if ($expressionArr.Length -gt 1) {
        $value = $expressionArr[1]
      }
      set-item -force -path "env:$name" -value $value
    }
  }
}
function pkill($name) {
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name) {
  Get-Process $name
}
function restartexplorer {
  Stop-Process -Name explorer -Force
  Start-Process "explorer.exe"
}
function removeduplicatedenvval {
  param(
    [string] $envKey,
    [ValidateSet('Machine','User')]
    [string] $envType,
    [Alias("h")]
    [switch] $help
  )
  if ($help) {
    log "removeduplicatedenvval ENV_KEY ENV_TYPE"
    return
  }
  if ([string]::IsNullOrEmpty($envKey) -or [string]::IsNullOrEmpty($envType)) {
    errorlog "Invalid envKey or envType"
  } else {
    if ($envType.Equals("Machine")) {
      $envType = [System.EnvironmentVariableTarget]::Machine
    } else {
      $envType = [System.EnvironmentVariableTarget]::User
    }
    [Environment]::GetEnvironmentVariable("$envKey", $envType)
    $noDupesPath = (([Environment]::GetEnvironmentVariable("$envKey", $envType) -split ';' | Select-Object -Unique) -join ';')
    [Environment]::SetEnvironmentVariable("$envKey", $noDupesPath, $envType)
  }
}
function setenv {
  param(
    [string] $envKey,
    [string] $envValue,
    [ValidateSet('Machine','User')]
    [string] $envType,
    [Alias("h")]
    [switch] $help
  )
  if ($help) {
    log "setenv ENV_KEY ENV_VALUE ENV_TYPE"
    return
  }
  if ([string]::IsNullOrEmpty($envKey) -or [string]::IsNullOrEmpty($envType)) {
    errorlog "Invalid envKey or envType"
  } else {
    if ($envType.Equals("Machine")) {
      $envType = [System.EnvironmentVariableTarget]::Machine
    } else {
      $envType = [System.EnvironmentVariableTarget]::User
    }
    [Environment]::SetEnvironmentVariable("$envKey", "$envValue", "$envType")
  }
}
function deleteenv {
  param(
    [string] $envKey,
    [ValidateSet('Machine','User')]
    [string] $envType,
    [Alias("h")]
    [switch] $help
  )
  if ($help) {
    log "deleteenv ENV_KEY ENV_TYPE"
    return
  }
  if ([string]::IsNullOrEmpty($envKey) -or [string]::IsNullOrEmpty($envType)) {
    errorlog "Invalid envKey or envType"
  } else {
    if ($envType.Equals("Machine")) {
      $envType = [System.EnvironmentVariableTarget]::Machine
    } else {
      $envType = [System.EnvironmentVariableTarget]::User
    }
    [Environment]::SetEnvironmentVariable("$envKey", [NullString]::Value, "$envType")
  }
}
function createservice {
  param(
    [string] $name,
    [string] $executablePath,
    [string] $displayName
  )
  if ([string]::IsNullOrEmpty($name) -or [string]::IsNullOrEmpty($executablePath) -or !(fileexists "$executablePath")) {
    errorlog "Invalid name: $name or executable path: $executablePath"
  } else {
    if ([string]::IsNullOrEmpty($name)) {
      sudo sc.exe create "$name" binPath="$executablePath" type=own start=auto DisplayName="$displayName"
    } else {
      sudo sc.exe create "$name" binPath="$executablePath" type=own start=auto
    }
  }
}
function deleteservice($name) {
  sudo sc.exe stop "$name"
  sudo sc.exe delete "$name"
}
function createtask {
  param([string] $name, [string] $executable, [string] $arguments, [switch] $isPowershellScript, [switch] $asAdmin)
  $action = ""
  $runLevel = "Limited"
  deletetask "$name"
  if ($asAdmin) {
    $runLevel = "Highest"
  }

  # Creating a launch schedule
  $trigger = New-ScheduledTaskTrigger -AtLogon

  # Action to execute
  if ($isPowershellScript) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy ByPass & '${executable}' '${arguments}'"
  } else {
    $action = New-ScheduledTaskAction -Execute "$executable" -Argument "$arguments"
  }
  $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel $runLevel

  # (for laptops)
  $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
  $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal

  # Registration of the task
  Register-ScheduledTask "$name" -InputObject $task
}
function deletetask {
  param([string] $name)
  # We remove registration of the task if it already exists
  ($is_job_already_created = Get-ScheduledTask -TaskName "$name") 2> $null;
  if ($is_job_already_created) {
    Unregister-ScheduledTask -Confirm:$false -TaskName "$name" | Start-Sleep 3
  }
}
function sudopwsh {
  sudo powershell.exe -Command $args
}
function gsudopwsh {
  gsudo powershell.exe -Command $args
}
function delalias {
  param(
    [string] $name,
    [Alias("h")]
    [switch] $help
  )
  if ($help) {
    log "delalias NAME"
    return
  }
  # Create powershell alias file
  $profilePowershellAlias = "$home\.otherapps\powershell-alias.ps1"
  if (!(fileexists "$profilePowershellAlias")) {
    $profilePowershellCustom = "$home\.otherapps\powershell-profile-custom.ps1"
    if (!(filecontain "$profilePowershellCustom" "$profilePowershellAlias")) {
      writefile "$profilePowershellCustom" ". '$profilePowershellAlias'" -append
    }
  }
  # Delete alias
  $aliasCmd = "Get-Alias | ForEach-Object { if (`$_.Name -eq '$name') { Remove-Item Alias:$name -Force }}"
  if (!(filecontain "$profilePowershellAlias" "$aliasCmd")) {
    writefile "$profilePowershellAlias" "$aliasCmd" -append
  }
}
