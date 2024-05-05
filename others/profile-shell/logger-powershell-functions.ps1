# Author: José M. C. Noronha

function log {
    param([string] $message, [switch] $keepLine, [string] $color)
    if ($keepLine) {
        if (! [string]::IsNullOrEmpty($color)) {
            Write-Host -NoNewline "$message" -ForegroundColor $color
        }
        else {
            Write-Host -NoNewline "$message"
        }
    }
    else {
        if (! [string]::IsNullOrEmpty($color)) {
            Write-Host "$message" -ForegroundColor $color
        }
        else {
            Write-Host "$message"
        }
    }
}
function debuglog {
    param([string] $message, [switch] $keepLine)
    log "[" -keepLine
    log "DEBUG" -keepLine
    log "] " -keepLine
    if ($keepLine) {
        log "$message" -keepLine
    }
    else {
        log "$message"
    }
    
}
function errorlog {
    param([string] $message, [switch] $keepLine)
    log "[" -keepLine
    log "ERROR" -color "Red" -keepLine
    log "] " -keepLine
    if ($keepLine) {
        log "$message" -keepLine
    }
    else {
        log "$message"
    }
    
}
function infolog {
    param([string] $message, [switch] $keepLine)
    log "[" -keepLine
    log "INFO" -color "Blue" -keepLine
    log "] " -keepLine
    if ($keepLine) {
        log "$message" -keepLine
    }
    else {
        log "$message"
    }
}
function warnlog {
    param([string] $message, [switch] $keepLine)
    log "[" -keepLine
    log "WARN" -color "Yellow" -keepLine
    log "] " -keepLine
    if ($keepLine) {
        log "$message" -keepLine
    }
    else {
        log "$message"
    }
}
function oklog {
    param([string] $message, [switch] $keepLine)
    log "[" -keepLine
    log "OK" -color "Green" -keepLine
    log "] " -keepLine
    if ($keepLine) {
        log "$message" -keepLine
    }
    else {
        log "$message"
    }
}
function promptlog {
    param([string] $message)
    log ">>> " -color "DarkGray" -keepLine
    log "$message"
}
function titlelog {
    param([string] $message)
    $message_len = $message.Length
    $separator = ""
    for ($i = 1; $i -le $message_len + 8; $i++) {
        $separator = "#${separator}"
    }
    log "$separator"
    log "##  $message  ##"
    log "$separator"
}
function headerlog {
    param([string] $message)
    log "##  $message  ##"
}
function separatorlog {
    param(
        [number] $length
    )
    $message = "# "
    if ($length -lt 5) {
        $length = 6
    }
    For ($i = 1; $i -le ($length - 4); $i++) {
        $message = "${message}-"
    }
    message="$message #"
    log "$message"
}
