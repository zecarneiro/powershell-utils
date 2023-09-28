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