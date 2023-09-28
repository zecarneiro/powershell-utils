# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function compile {
    param (
        [string] $cmd,
        [string] $cwd
    )
    $currentDir = "$pwd"
    log "Compiling..."
    Set-Location "$cwd"
    evaladvanced "$cmd"
    Set-Location "$currentDir"
}