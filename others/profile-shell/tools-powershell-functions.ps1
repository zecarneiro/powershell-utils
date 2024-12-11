# Author: José M. C. Noronha

function cutadvanced {
    param(
        [string] $data,
        [string] $delimiter,
        [ValidateSet("L", "R", IgnoreCase = $false)]
        [string] $direction,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "cutadvanced -data DATA -delimiter DELIMITIER -direction [L|R]"
        return
    }
    if ($data.Length -gt 0) {
        if ($direction -eq "R") {
            $pos = ($data.IndexOf($delimiter) + $delimiter.Length)
            return $data.Substring($pos)
        }
        elseif ($direction -eq "L") {
            return $data.Substring(0, $data.IndexOf($delimiter))
        }
        return $data
    }
}
function extract {
    param(
        [string] $file,
        [Alias("d")]
        [string] $destination
    )
    if ((fileexists "$file")) {
        if ([string]::IsNullOrEmpty($destination) -or $destination -eq " ") {
            $destination = "$pwd"
        } else {
            mkdir "$destination"
        }
        switch (fileextension "$file") {
            ".zip" { Expand-Archive -LiteralPath "$file" -DestinationPath "$destination" }
            Default { infolog "don't know how to extract '$file'..." }
        }
    }
    else {
        errorlog "'$file' is not a valid file!"
    }
}
function openurl {
    param ([string] $url)
    if (![string]::IsNullOrEmpty($url)) {
        Start-Process "$url"
    }
}
function hasinternet {
    return ((Test-Connection 8.8.8.8 -Count 1 -Quiet) -or (Test-Connection 8.8.4.4 -Count 1 -Quiet) -or (Test-Connection time.google.com -Count 1 -Quiet))
}
function mypubip {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
function download {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$url,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [Alias("outfile")]
        [string]$file,
        [Alias("h")]
        [switch] $help
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
        if ($help) {
            log "download -url URL -file FILE"
            return
        }
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'

            if (!(hasinternet)) {
                throw "No Internet connection available"
            }
            infolog "Downloading from URL: $url"
        
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
            $fileProgress = (filename "$file")
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($fileProgress)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "$($fileProgress)" -ValueSuffix "MB" -Complete
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
function df { get-volume }
function wslshutdown {
    param([switch] $force)
    if ($force) {
        evaladvanced "sudo taskkill /F /IM wslservice.exe"
    }
    else {
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
        }
        else {
            $data = $ramData
        }
    }
    if ($processor) {
        $processorData = "processors=${processor}"
        if ($null -ne $data) {
            $data = "${data}`n$processorData"
        }
        else {
            $data = $processorData
        }
    }
    if ($null -ne $data) {
        $data = "[wsl2]`n${data}"
        writefile "$configFile" "$data"
        wslshutdown
    }
}
function exitwithmsg {
    param(
        [string] $message,
        [int] $code = 0,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "exitwithmsg MSG CODE(Default = 0)"
        return
    }
    if (![string]::IsNullOrEmpty($message)) {
        infolog "$message"
    }
    exit $code
}
function runlineascommand {
	param(
        [string] $file,
        [string] $headerKey
    )
	$prefix_sufix_key="######"
	$allKey="$prefix_sufix_key ALL $prefix_sufix_key"
	$headerKey="$prefix_sufix_key $headerKey $prefix_sufix_key"
	$canRun=$false
	foreach ($line in Get-Content "$file") {
		if(($line -like "${prefix_sufix_key}*")) {
			if (($line -like "${allKey}*") -or ($line -like "${headerKey}*")) {
				$canRun=$true
			} else {
				$canRun=$false
			}
		}
		if ($canRun -and ![string]::IsNullOrEmpty($line)) {
			if (($line -like "${prefix_sufix_key}*")) {
				Write-Host "$line"
			} else {
				evaladvanced "$line"
			}
		}
    }
}
Set-Alias -Name 'now' -Value "date"
function lhiden() {
    cmd.exe /c dir "$pwd" /adh
}
function resolvePath($pathStr) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($pathStr)
}
function waituntil {
    param([int] $seconds)
    timeout /t $seconds
}
function wintowslpath($path) {
    wsl -- wslpath -u "'$path'"
}
function wsltowinpath($path) {
    wsl -- wslpath -w "'$path'"
}
function runbashscriptWSL {
	param([string] $scriptOrigPath, [bool] $withSudo, [string] $distro, [string[]] $arguments = @())
	$scriptPath = (wintowslpath "$scriptOrigPath")
    if (![string]::IsNullOrEmpty($distro)) {
        $distro = "-d $distro"
    }
    $argumentsStr = ""
    foreach ($argument in $arguments) {
        $argumentsStr = "$argumentsStr '$argument'"
    }
	evaladvanced "wsl $distro -- chmod +x `"$scriptPath`""
	if ($withSudo) {
        $command = "sudo '$scriptPath' $argumentsStr"
	} else {
        $command = "source '$scriptPath' $argumentsStr"
	}
    evaladvanced "wsl $distro -- $command"
}
function runExeFile {
    param([string] $exeFile)
    if ((fileexists "$exeFile") -or (commandexists "$exeFile")) {
        evaladvanced "Start-Process '$exeFile' -Wait"
    }
}
function runMsixFile {
    param([string] $exeFile)
    if ((fileexists "$exeFile")) {
        evaladvanced "sudopwsh Start-Process 'Add-AppxPackage' -ArgumentList '-Path `"$exeFile`"' -Wait"
    }
}
function runFilesByPath {
    param([string] $pathWithFiles)
    if ((directoryexists "$pathWithFiles")) {
        $exeExtArr = @("exe", "msixbundle", ".msi")
        foreach ($exeExt in $exeExtArr) {
            Get-ChildItem -Path "$pathWithFiles" -Filter "*.$exeExt" | ForEach-Object {
                $fileFull = $_.FullName
                if ("$exeExt" -eq "msixbundle") {
                    runMsixFile "$fileFull"
                } elseif ("$exeExt" -eq "exe") {
                    runExeFile "$fileFull"
                } elseif ("$exeExt" -eq "msi") {
                    runExeFile "$fileFull"
                }
            }
        }
    }
    infolog "Execution of all files on '$pathWithFiles' it's done."
    pause
}
function set-full-access {
    param([string] $file)
    $acl = "$file" | Get-Acl -ErrorAction Stop
    $rule = [security.accesscontrol.filesystemaccessrule]::new($Env:username, 'FullControl', 'Allow')
    $acl.AddAccessRule($rule)
    $acl | Set-Acl
}
