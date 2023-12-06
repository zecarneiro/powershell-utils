# Author: José M. C. Noronha
# Some code has source: https://github.com/ChrisTitusTech/powershell-profile

# BASH-LIKE TAB COMPLETION IN POWERSHELL
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ---------------------------------------------------------------------------- #
#                                    SYSTEM                                    #
# ---------------------------------------------------------------------------- #
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
function evaladvanced($expression) {
    promptlog "$expression"
    Invoke-Expression $expression
}
Function commandexists($command) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
}
function addaliasf {
    param(
        [string] $name,
        [string] $command,
        [switch] $passArgs
    )
    $profilePowershellAliasName = "powershell-alias.ps1"
    $profilePowershellAlias = "$home\$profilePowershellAliasName"
    if (!(fileexists "$profilePowershellAlias")) {
        $profilePowershell = $PROFILE.CurrentUserAllHosts
        touch "$profilePowershellAlias"
        if ($null -eq (Select-String -Path "$profilePowershell" -Pattern "$profilePowershellAliasName")) {
            Write-Output ". `"$profilePowershellAlias`"" | Tee-Object "$profilePowershell" -Append | Out-Null
        }
    }
    if ($null -ne (Select-String -Path "$profilePowershellAlias" -Pattern "function $name {")) {
        delfilelines -file "$profilePowershellAlias" -match "$name"
    }
    if ($passArgs) {
        Write-Output "function $name {$command `$args}" | Tee-Object "$profilePowershellAlias" -Append | Out-Null
    } else {
        Write-Output "function $name {$command}" | Tee-Object "$profilePowershellAlias" -Append | Out-Null
    }
}
function addalias {
    param(
        [string] $name,
        [string] $value
    )
    $profilePowershellAliasName = "powershell-alias.ps1"
    $profilePowershellAlias = "$home\$profilePowershellAliasName"
    if (!(fileexists "$profilePowershellAlias")) {
        $profilePowershell = $PROFILE.CurrentUserAllHosts
        touch "$profilePowershellAlias"
        if ($null -eq (Select-String -Path "$profilePowershell" -Pattern "$profilePowershellAliasName")) {
            Write-Output ". `"$profilePowershellAlias`"" | Tee-Object "$profilePowershell" -Append | Out-Null
        }
    }
    if ($null -ne (Select-String -Path "$profilePowershellAlias" -Pattern "Set-Alias -Name `"$name`"")) {
        delfilelines -file "$profilePowershellAlias" -match "Set-Alias -Name `"$name`""
    }
    Write-Output "Set-Alias -Name `"$name`" -Value $value" | Tee-Object "$profilePowershellAlias" -Append
}
function isadmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    return ($currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
}
function editalias {
    $profilePowershellAliasName = "$home\powershell-alias.ps1"
    if ((fileexists "$profilePowershellAliasName")) {
        notepad "$profilePowershellAliasName"
    }
}
function editprofile {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    } else {
        notepad $profile.CurrentUserAllHosts
    }
}
function editcustomprofile {
    $profileCustom = "$home\powershell-profile-custom.ps1"
    if ((fileexists "$profileCustom")) {
        notepad "$profileCustom"
    }
}
function reloadprofile {
    . $PROFILE.CurrentUserAllHosts
}
function ver {
    systeminfo | findstr /B /C:"OS Name" /B /C:"OS Version"
}
function uptime {
    #Windows Powershell only
	If ($PSVersionTable.PSVersion.Major -eq 5 ) {
		Get-WmiObject win32_operatingsystem |
        Select-Object @{EXPRESSION={ $_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
	} Else {
        net statistics workstation | Select-String "since" | foreach-object {$_.ToString().Replace('Statistics since ', '')}
    }
}
function ix ($file) {
    curl.exe -F "f:1=@$file" ix.io
}
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
function export($name, $value) {
    set-item -force -path "env:$name" -value $value
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
function Env: { Set-Location Env: }
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
# Find out if the current user identity is elevated (has admin rights)
$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ((isadmin)) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}
function prompt { 
    if ($isAdmin) {
        "[" + (Get-Location) + "] # " 
    } else {
        "[" + (Get-Location) + "] $ "
    }
}


# ---------------------------------------------------------------------------- #
#                                   DIRECTORY                                  #
# ---------------------------------------------------------------------------- #
function gouserotherapps {
    $directory = "$home\otherapps"
    if (!(directoryexists "$directory")) {
        mkdir -p "$directory"
    }
    Set-Location "$directory"
}
function gouserconfig {
    $directory = "$home\.config"
    if (!(directoryexists "$directory")) {
        mkdir -p "$directory"
    }
    Set-Location "$directory"
}
function directoryexists($directory) {
    if (Test-Path -Path "$directory") {
        RETURN $true
    }
    RETURN $false
}
function deletedirectory {
    param([string] $directory)
    if (![string]::IsNullOrEmpty($directory) -and (directoryexists "$directory")) {
        evaladvanced "Remove-Item '$directory' -Recurse -Force"
    }
}
function deleteemptydirs () {
	Get-ChildItem -Path "$pwd" -Recurse -Directory | Remove-Item -Force -Recurse -Verbose
}
function gohome { Set-Location "$home" }
function cd.. { Set-Location .. }
Set-Alias -Name ".." -Value cd..
function cd... { Set-Location ..\.. }
Set-Alias -Name "..." -Value cd...
function cd.... { Set-Location ..\..\.. }
Set-Alias -Name "...." -Value cd....
function cd..... { Set-Location ..\..\..\.. }
Set-Alias -Name "....." -Value cd.....
Set-Alias -Name mkdir -Value mkdirunix.exe
function ldir {
    param([string] $cwd)
    if ([string]::IsNullOrEmpty($cwd)) {
        (Get-ChildItem -Directory | ForEach-Object {$_.FullName})
    }
    (Get-ChildItem -Path "$cwd" -Directory | ForEach-Object {$_.FullName})
}
function dirname($file) {
    Write-Output ([System.IO.Path]::GetDirectoryName($file))
}


# ---------------------------------------------------------------------------- #
#                                     FILE                                     #
# ---------------------------------------------------------------------------- #
function fileexists($file) {
    if (Test-Path -Path "$file" -PathType Leaf) {
        RETURN $true
    }
    RETURN $false
}
function fileextension($file) {
    Write-Output ([System.IO.Path]::GetExtension("$file"))
}
function filename($file) {
    Write-Output ([System.IO.Path]::GetFileNameWithoutExtension("$file"))
}
function delfilelines {
    param (
        [string] $file,
        [string] $match
    )
    if ($null -ne (Select-String "$file" -Pattern "$match")) {
        $file_tmp = $file + "tmp"
        Get-Content $file | Where-Object {$_ -notmatch $match} | Set-Content -Path $file_tmp
        Move-Item "$file_tmp" -Destination "$file" -Force
    }
}
function countfiles { (Get-ChildItem | Measure-Object).Count }
function deletefile {
    param ([string] $file)
    if ((fileexists "$file")) {
        evaladvanced "Remove-Item `"$file`" -Recurse -Force"
    }
}
function findfile($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
function movefilestoparent {
    Get-ChildItem -Path "$pwd" -Recurse -File | Move-Item -Destination "$pwd" -Verbose
}
function lf {
    param([string] $cwd)
    if ([string]::IsNullOrEmpty($cwd)) {
        (Get-ChildItem -File | ForEach-Object {$_.FullName})
    }
    (Get-ChildItem -Path "$cwd" -File | ForEach-Object {$_.FullName})
}
function basename($file) {
    Write-Output ([System.IO.Path]::GetFileName($file))
}
function ll { Get-ChildItem -Path $pwd -File }
function touch($file) {
    "" | Tee-Object "$file"
}


# ---------------------------------------------------------------------------- #
#                                     DISK                                     #
# ---------------------------------------------------------------------------- #
function df { get-volume }


# ---------------------------------------------------------------------------- #
#                             Secure Hash Algorithm                            #
# ---------------------------------------------------------------------------- #
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }


# ---------------------------------------------------------------------------- #
#                                     TOOLS                                    #
# ---------------------------------------------------------------------------- #
function cutadvanced {
    param(
        [string] $data,
        [string] $delimiter,
        [ValidateSet("L", "R", IgnoreCase = $false)]
        [string]
        $direction
    )
    if ($data.Length -gt 0) {
        if ($direction -eq "R") {
            $pos = ($data.IndexOf($delimiter) + $delimiter.Length)
            return $data.Substring($pos)
        } elseif ($direction -eq "L") {
            return $data.Substring(0, $data.IndexOf($delimiter))
        }
        return $data
    }
}
function extract ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}
function cpadvanced {
    param(
        [string] $source,
        [string] $destination
    )
    Copy-Item "$source" -Destination "$destination" -Recurse
}
function mvadvanced {
    param(
        [string] $source,
        [string] $destination
    )
    Move-Item "$source" -Destination "$destination"
}
function mktemp {
    param(
        [switch] $d,
        [switch] $directory,
        [Parameter(mandatory=$false)]
        [string]
        $Extension
    )
    $randomfile = [System.IO.Path]::GetRandomFileName()
    if ($Extension) {
        $randomfile = [System.IO.Path]::ChangeExtension($randomfile, $Extension)
    }
    $parent = [System.IO.Path]::GetTempPath()
    $tmpfile = (Join-Path $parent $randomfile)
    Write-Output $tmpfile
    if ($d -or $directory) {
        New-Item -ItemType Directory -Path "$tmpfile" | Out-Null
    } else {
        touch "$tmpfile"
    }
}

function wslshutdown {
    param(
        [switch] $force
    )
    if ($force) {
        evaladvanced "sudo taskkill /F /IM wslservice.exe"
    } else {
        evaladvanced "wsl --shutdown"
    }
}

function wslconfigadvanced {
    $configFile = "$home\.wslconfig"
    infolog "This confofigurations only works on windows 11 or newer!!"
    $ram = Read-Host "Insert max of RAM(GB) - ENTER TO SKIP"
    $processor = Read-Host "Insert max of Processor - ENTER TO SKIP"
    $data = $null
    if ($ram) {
        $ramData = "memory=${ram}GB"
        if ($null -ne $data) {
            $data = "${data}`n$ramData"
        } else {
            $data = $ramData
        }
    }
    if ($processor) {
        $processorData = "processors=${processor}"
        if ($null -ne $data) {
            $data = "${data}`n$processorData"
        } else {
            $data = $processorData
        }
    }
    if ($null -ne $data) {
        $data = "[wsl2]`n${data}"
        Write-Output "$data" | Tee-Object "$configFile" | Out-Null
        wslshutdown
    }
}

Set-Alias -Name rmunix -Value rmunix.exe


# ---------------------------------------------------------------------------- #
#                                  NETWORKING                                  #
# ---------------------------------------------------------------------------- #
function openurl {
    param ([string] $url)
    if ([string]::IsNullOrEmpty($url)) {
        ErrorLog "Invalid URL"
    } else {
        Start-Process "$url"
    }
}
function hasinternet {
    return ((Test-Connection 8.8.8.8 -Count 1 -Quiet) -or (Test-Connection 8.8.4.4 -Count 1 -Quiet) -or (Test-Connection time.google.com -Count 1 -Quiet))
}
function mypubip { (Invoke-WebRequest http://ifconfig.me/ip ).Content }
function download {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$url,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$file 
    )
    Begin {
        function Show-Progress {
            param (
                # Enter total value
                [Parameter(Mandatory)]
                [Single]$TotalValue,
        
                # Enter current value
                [Parameter(Mandatory)]
                [Single]$CurrentValue,
        
                # Enter custom progresstext
                [Parameter(Mandatory)]
                [string]$ProgressText,
        
                # Enter value suffix
                [Parameter()]
                [string]$ValueSuffix,
        
                # Enter bar lengh suffix
                [Parameter()]
                [int]$BarSize = 40,

                # show complete bar
                [Parameter()]
                [switch]$Complete
            )
            
            # calc %
            $percent = $CurrentValue / $TotalValue
            $percentComplete = $percent * 100
            if ($ValueSuffix) {
                $ValueSuffix = " $ValueSuffix" # add space in front
            }
            if ($psISE) {
                Write-Progress "$ProgressText $CurrentValue$ValueSuffix of $TotalValue$ValueSuffix" -id 0 -percentComplete $percentComplete            
            }
            else {
                # build progressbar with string function
                $curBarSize = $BarSize * $percent
                $progbar = ""
                $progbar = $progbar.PadRight($curBarSize, [char]9608)
                $progbar = $progbar.PadRight($BarSize, [char]9617)
        
                if (!$Complete.IsPresent) {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($CurrentValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"
                }
                else {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($TotalValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"                    
                }                
            }   
        }
    }
    Process {
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'

            if (!(hasinternet)) {
                throw "No Internet connection available"
            }
        
            # invoke request
            $request = [System.Net.HttpWebRequest]::Create($url)
            $response = $request.GetResponse()
  
            if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
                throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$url'."
            }
  
            if ($file -match '^\.\\') {
                $file = Join-Path (Get-Location -PSProvider "FileSystem") ($file -Split '^\.')[1]
            }
            
            if ($file -and !(Split-Path $file)) {
                $file = Join-Path (Get-Location -PSProvider "FileSystem") $file
            }

            if ($file) {
                $fileDirectory = $([System.IO.Path]::GetDirectoryName($file))
                if (!(Test-Path($fileDirectory))) {
                    [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
                }
            }

            [long]$fullSize = $response.ContentLength
            $fullSizeMB = $fullSize / 1024 / 1024
  
            # define buffer
            [byte[]]$buffer = new-object byte[] 1048576
            [long]$total = [long]$count = 0
  
            # create reader / writer
            $reader = $response.GetResponseStream()
            $writer = new-object System.IO.FileStream $file, "Create"
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($file)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($file)" -ValueSuffix "MB" -Complete
                    $finalBarCount++
                }
            } while ($count -gt 0)
            Write-Host -NoNewLine "`n"
        }
        catch {
            $ExeptionMsg = $_.Exception.Message
            ErrorLog "$ExeptionMsg"
        }
  
        finally {
            # cleanup
            if ($reader) { $reader.Close() }
            if ($writer) { $writer.Flush(); $writer.Close() }
        
            $ErrorActionPreference = $storeEAP
            [GC]::Collect()
        }    
    }
}


# ---------------------------------------------------------------------------- #
#                                    LOGGER                                    #
# ---------------------------------------------------------------------------- #
function log {
    param([string] $message, [bool] $keepLine, [string] $color)
    if ($keepLine) {
        if (! [string]::IsNullOrEmpty($color)) {
            Write-Host -NoNewline "$message" -ForegroundColor $color
        } else {
            Write-Host -NoNewline "$message"
        }
    } else {
        if (! [string]::IsNullOrEmpty($color)) {
            Write-Host "$message" -ForegroundColor $color
        } else {
            Write-Host "$message"
        }
    }
}
function errorlog {
    param([string] $message, [bool] $keepLine)
    log "[" -keepLine $true
    log "ERROR" -color "Red" -keepLine $true
    log "] " -keepLine $true
    log "$message" -keepLine $keepLine
}
function infolog {
    param([string] $message, [bool] $keepLine)
    log "[" -keepLine $true
    log "INFO" -color "Blue" -keepLine $true
    log "] " -keepLine $true
    log "$message" -keepLine $keepLine
}
function warnlog {
    param([string] $message, [bool] $keepLine)
    log "[" -keepLine $true
    log "WARN" -color "Yellow" -keepLine $true
    log "] " -keepLine $true
    log "$message" -keepLine $keepLine
}
function oklog {
    param([string] $message, [bool] $keepLine)
    log "[" -keepLine $true
    log "OK" -color "Green" -keepLine $true
    log "] " -keepLine $true
    log "$message" -keepLine $keepLine
}
function promptlog {
    param([string] $message)
    log ">>> " -color "DarkGray" -keepLine $true
    log "$message"
}
function titlelog {
    param([string] $message)
	$message_len=$message.Length
	$separator=""
	for ($i=1; $i -le $message_len+8; $i++) {
        $separator="#${separator}"
    }
	log "$separator"
	log "##  $message  ##"
	log "$separator"
}
function headerlog {
	param([string] $message)
	log "##  $message  ##"
}

# ---------------------------------------------------------------------------- #
#                                      GIT                                     #
# ---------------------------------------------------------------------------- #
function gitrepobackup { git clone --mirror $args }
function gitreporestorebackup { git push --mirror $args }
function gitbash { & "$env:PROGRAMFILES\Git\bin\bash.exe" $args }
function gitundolastcommit { git reset --soft HEAD~1 }
function gitresethardorigin {
    $current_branch_name = (git branch --show-current)
    git reset --hard origin/$current_branch_name
}
function gitresetfile() {
    param(
        [string] $fileName,
        [string] $branch
    )
    if ((fileexists "$fileName")) {
        if ([string]::IsNullOrEmpty($branch)) {
            $branch = "origin/master"
        }
        evaladvanced "git checkout $branch '$fileName'"
    } else {
		errorlog "Invalid file - $fileName"
    }
}


# ---------------------------------------------------------------------------- #
#                                PACKAGES UTILS                                #
# ---------------------------------------------------------------------------- #
function npmupgrade { evaladvanced "npm outdated -g; npm update -g" }

function wingetupgrade {
    infolog "To upgrade 'Windows Terminal', go to Microsoft Store and search for 'Windows Terminal'"
    evaladvanced "winget upgrade --all"
}
function wingetuninstall { winget uninstall --purge $args }

function scoopupgrade { evaladvanced "scoop update --all" }
function scoopuninstall { scoop uninstall --purge $args }
function scoopclean { evaladvanced "scoop cleanup --all" }

function wslupgrade { evaladvanced "sudo wsl.exe --update" }

function systemupgrade { npmupgrade; log; wingetupgrade; log; scoopupgrade; log; wslupgrade }
function systemclean { scoopclean }
