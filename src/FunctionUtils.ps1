# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #      
function trim {
    param (
        [string] $d,
        [string] $c = "`n "
    )
    $data = $d; $characters = $c
    if ($data.Length -gt 0) {
        $data = $data.Trim($characters)
    }
    return $data
}

function get_all_function_name {
    param([string] $script)
    [ref]$tokens      = $null
    [ref]$parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile("$PWD\$SCRIPT", $tokens, $parseErrors)
    $ast.EndBlock.Statements | Where-Object { $_.Name } | ForEach-Object { Write-Host $_.Name }
}