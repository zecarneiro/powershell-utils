# Author: José M. C. Noronha

# Imports Modules
Import-Module scoop-completion

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
	evaladvanced "winget upgrade winget"
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
function scoopclean {
	evaladvanced "scoop cleanup --all"
	evaladvanced "scoop cache rm *"
}
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
#                               UPDATERS SCRIPTS                               #
# ---------------------------------------------------------------------------- #
function installupdater($updater_script, $scriptname) {
	$updater_dir = "$home\.otherapps\updaters"
	$scriptname = $(basename "$updater_script")
	mkdir "$updater_dir"
	infolog "Installing '$scriptname'"
	Copy-Item "$updater_script" "$updater_dir"
	oklog "Done"
}

function updatersupgrade($scriptname) {
	$currentdir = "$pwd"
	$updater_dir = "$home\.otherapps\updaters"
	if (directoryexists "$updater_dir") {
		Get-ChildItem "$updater_dir" | Foreach-Object {
			$script = $_.FullName
			$updatername = $(basename "$script")
			if ([string]::IsNullOrEmpty($scriptname) -or $scriptname -eq "$updatername") {
				promptlog "$script"
				. "$script"
			}
		}
	}
    Set-Location "$currentdir"
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
	log; updatersupgrade
}
function systemclean {
	scoopclean
}

function startapps($filter) {
	$command_to_run = "Get-StartApps"
	if (![string]::IsNullOrEmpty($filter)) {
		$command_to_run = "${command_to_run} | grep ${filter}"
	}
	evaladvanced "${command_to_run}" $true
}
