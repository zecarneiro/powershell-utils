# Author: José M. C. Noronha
# Some code has source: https://github.com/ChrisTitusTech/powershell-profile

function reboot {
  $userInput = (Read-Host "Will be reboot PC. Continue(y/N)? ")
  if ($userInput -eq "Y" -or $userInput -eq "y") {
    shutdown /r /t 0
  }
}
function shutdown {
  $userInput = (Read-Host "Will be shutdown PC. Continue(y/N)? ")
  if ($userInput -eq "Y" -or $userInput -eq "y") {
    shutdown /s /t 0
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
      writefile "$profilePowershellAlias" "function $name {$command ```$args}" -append
    } else {
      writefile "$profilePowershellAlias" "function $name {$command}" -append
    }
  }
}
function isadmin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  return ($currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
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
function reloadprofile {
  $profilePowershell = $PROFILE.CurrentUserAllHosts
  if (!(Test-Path -Path "$profilePowershell" -PathType Leaf)) {
    infolog "Creating Powershell Script profile to run when powrshell start: $profilePowershell"
    New-Item $profilePowershell -ItemType file -Force
  }
  . "$profilePowershell"
}
function ver {
  systeminfo | findstr /B /C:"OS Name" /B /C:"OS Version"
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
function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
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
  taskkill /f /IM explorer.exe
  Start-Process explorer.exe
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

# Find out if the current user identity is elevated (has admin rights)
$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ((isadmin)) {
  $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}
function prompt {
  if ($isAdmin) {
    "[" + (Get-Location) + "] # " 
  }
  else {
    "[" + (Get-Location) + "] $ "
  }
}