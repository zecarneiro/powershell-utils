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
function systemupgrade {
	npmupgrade
	log; wingetupgrade
	log; scoopupgrade
	log; wslupgrade
}
function systemclean {
	scoopclean
}
