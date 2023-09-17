
# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function ReadUserKeyboard {
    param([string] $message)
    $line = Read-Host "$message"
    return $line;
}
  
function WaitForAnyKeyPressed {
    param ([string] $message)
    Write-Host -NoNewLine "$message";
    $key = ($Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown"))
    LogLog ""
}

function Eval {
    param([string] $expression, [bool] $verbose = $true)
    if ($verbose) {
        PromptLog "$expression"
    }
    Invoke-Expression $expression
}

function CommandExist {
    param ([string] $command)
    if (!([string]::IsNullOrEmpty((where.exe "$command")))) {
        return $true
    }
    return $false
}

function GetEnvironmentVariables {
    param ([string] $name)
    if ([string]::IsNullOrEmpty($name)) {
        return [System.Environment]::GetEnvironmentVariables()
    }
    return [System.Environment]::GetEnvironmentVariable($name)
}