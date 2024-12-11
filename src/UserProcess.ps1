# Author: José M. C. Noronha
# IMPORTANT: Save this script always with UTF-8 with BOM

$HOME_DIR_INVALID_REGEX = '[!@#$%^&*(),?"":{}|<>=´]|[à-ü]|[À-Ü]'

function is_valid_home_dir {
    $homeDirBasename = [System.IO.Path]::GetFileName("$home")
    $isValid = $true
    switch -regex ($homeDirBasename){
        "$HOME_DIR_INVALID_REGEX" {
            $isValid = $False
        }
        Default {
            $homeDirBasenameArr = $homeDirBasename.Split(" ")
            if ($homeDirBasenameArr.Length -gt 1) {
                $isValid = $False
            }
        }
    }
    if (!($isValid)) {
        infolog "Your home dir is: $home"
        infolog "Your home dir basename is: $homeDirBasename"
    }
    return $isValid
}

function show_rules_username {
    titlelog "Usernames must"
    log "-> Start with an alphabetic character"
    log "-> Not contain spaces or `"@`""
    log "-> Be 20 characters or fewer for Windows"
    log "-> Contain only valid Unix Characters - letters, numbers, `"-`", `".`", and `"_`""
    log "-> Be different from the device host name on Windows"
    log "-> When setting for a Windows device, usernames can't end with a period (.) or else they will not appear on the device login screen"
}

function change_user_full_name {
    $username = $env:username
    Get-WmiObject Win32_UserAccount | ForEach-Object {
        $name = $_.Name
        $fullname = $_.FullName
        if ("$name" -eq "$username") {
            titlelog "Change User Full name(Display name on start menu, etc)"
            log "Current user full name: $fullname"
            $newFullname = (read_user_keyboard "Insert the new full name for the username '$username' (PRESS ENTER TO KEEP)")
            if (!([string]::IsNullOrEmpty($newFullname)) -and "$newFullname" -ne "$fullname") {
                $UserAccount = Get-LocalUser -Name "$username"
                sudopwsh Set-LocalUser -Name "$username" -FullName "'$newFullname'"
                oklog "Change User Full name will be done when you logout or restart PC."
            }
        }
    } 
}