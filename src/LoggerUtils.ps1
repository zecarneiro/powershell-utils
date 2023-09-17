function LogLog {
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

function ErrorLog {
    param([string] $message, [bool] $keepLine)
    LogLog -message "[" -keepLine $true
    LogLog -message "ERROR" -color "Red" -keepLine $true
    LogLog -message "] " -keepLine $true
    LogLog -message "$message" -keepLine $keepLine
}

function InfoLog {
    param([string] $message, [bool] $keepLine)
    LogLog -message "[" -keepLine $true
    LogLog -message "INFO" -color "Blue" -keepLine $true
    LogLog -message "] " -keepLine $true
    LogLog -message "$message" -keepLine $keepLine
}

function WarnningLog {
    param([string] $message, [bool] $keepLine)
    LogLog -message "[" -keepLine $true
    LogLog -message "WARN" -color "Yellow" -keepLine $true
    LogLog -message "] " -keepLine $true
    LogLog -message "$message" -keepLine $keepLine
}

function SuccessLog {
    param([string] $message, [bool] $keepLine)
    LogLog -message "[" -keepLine $true
    LogLog -message "OK" -color "Green" -keepLine $true
    LogLog -message "] " -keepLine $true
    LogLog -message "$message" -keepLine $keepLine
}

function PromptLog {
    param([string] $message)
    LogLog -message ">>> " -color "DarkGray" -keepLine $true
    LogLog "$message"
}
