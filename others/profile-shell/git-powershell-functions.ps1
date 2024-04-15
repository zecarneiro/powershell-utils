# Author: José M. C. Noronha

function gitresethardorigin {
    $current_branch_name = (git branch --show-current)
    git reset --hard origin/$current_branch_name
}
function gitresetfile {
    param(
        [string] $fileName,
        [string] $branch,
        [Alias("h")]
        [switch] $help
    )
    if ($help) {
        log "gitresetfile FILENAME BRANCH"
        return
    }
    if ((fileexists "$fileName")) {
        if ([string]::IsNullOrEmpty($branch)) {
            $branch = "origin/master"
        }
        evaladvanced "git checkout $branch '$fileName'"
    } else {
		errorlog "Invalid file - $fileName"
    }
}
function gitrepobackup($url) {
    git clone --mirror "$url"
}
function gitreporestorebackup($url) {
    git push --mirror "$url"
}
function gitundolastcommit {
    git reset --soft HEAD~1
}
function gitbash {
    & "$env:PROGRAMFILES\Git\bin\bash.exe" $args
}
