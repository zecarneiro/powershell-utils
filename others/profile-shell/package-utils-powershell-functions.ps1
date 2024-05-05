# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                      NPM                                     #
# ---------------------------------------------------------------------------- #
function npmupgrade {
	evaladvanced "npm outdated -g"
	evaladvanced "npm update -g"
}
function npmlist($filter) {
	$command_to_run = "npm list -g --depth=0"
	if (![string]::IsNullOrEmpty($filter)) {
		$command_to_run = "${command_to_run} | grep ${filter}"
	}
	evaladvanced "${command_to_run}" $true
}

# ---------------------------------------------------------------------------- #
#                                    WINGET                                    #
# ---------------------------------------------------------------------------- #
function wingetupgrade {
	infolog "To upgrade 'Windows Terminal', go to Microsoft Store and search for 'Windows Terminal'"
	evaladvanced "winget upgrade --all"
}
function wingetuninstall { winget uninstall --purge $args }
function wingetlist($filter) {
	$command_to_run = "winget list"
	if (![string]::IsNullOrEmpty($filter)) {
		$command_to_run = "${command_to_run} | grep ${filter}"
	}
	evaladvanced "${command_to_run}" $true
}

# ---------------------------------------------------------------------------- #
#                                     SCOOP                                    #
# ---------------------------------------------------------------------------- #
function scoopupgrade { evaladvanced "scoop update --all" }
function scoopuninstall { scoop uninstall --purge $args }
function scoopclean { evaladvanced "scoop cleanup --all" }
function scooplist($filter) {
	$command_to_run = "scoop list"
	if (![string]::IsNullOrEmpty($filter)) {
		$command_to_run = "${command_to_run} | grep ${filter}"
	}
	evaladvanced "${command_to_run}" $true
}

# ---------------------------------------------------------------------------- #
#                                      WSL                                     #
# ---------------------------------------------------------------------------- #
function wslupgrade {
	evaladvanced "sudo wsl.exe --update"
}
function wsluninstall($distro) {
	evaladvanced "wsl --unregister $distro"
}
function wsllist($filter) {
	$command_to_run = "wsl --list --verbose"
	if (![string]::IsNullOrEmpty($filter)) {
		$command_to_run = "${command_to_run} | grep ${filter}"
	}
	evaladvanced "${command_to_run}" $true
}

# ---------------------------------------------------------------------------- #
#                                SYSTEM PACKAGES                               #
# ---------------------------------------------------------------------------- #
function powershellupgrade {
    if (!(hasinternet)) {
		Write-Host "No internet connection" -ForegroundColor Yellow
        return
    }

    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

function systemupgrade {
	npmupgrade
	log; wingetupgrade
	log; scoopupgrade
	log; powershellupgrade
	log; wslupgrade
}
function systemclean {
	scoopclean
}


