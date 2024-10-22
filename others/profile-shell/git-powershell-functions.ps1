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
function gitmovsubmodule($old, $new) {
    $newParentDir = (dirname "$new")
    try {
        mkdir "$newParentDir"
    }
    catch {
        infolog "Directory already exists: $newParentDir"
    }
    git mv "$old" "$new"
}
function gitaddscriptperm($script) {
    $scriptFilename = basename "$script"
    git update-index --chmod=+x "$script"
    git ls-files --stage | grep "$scriptFilename"
}
function gitcherrypickmaster($commit) {
    git cherry-pick -m 1 "$commit"
}
function gitcherrypickmastercontinue {
    git cherry-pick --continue
}
function gitclone($url) {
    git clone "$url"
}
function githubchangeurl() {
    $username = Read-Host "Github Username: "
    $token = Read-Host "Github Token: "
    $urlEndPath = Read-Host "Github URL end path(ex: AAA/bbb.gi): "
    $url="https://${username}:${token}@github.com/$urlEndPath"
    infolog "Set new github URL: $url"
    git remote set-url origin "$url"
}
function gitglobalconfig() {
    evaladvanced "git config --global core.autocrlf input"
    evaladvanced "git config --global core.fileMode false"
    evaladvanced "git config --global core.logAllRefUpdates true"
    evaladvanced "git config --global core.ignorecase true"
    evaladvanced "git config --global pull.rebase true"
    evaladvanced "git config --global --add safe.directory '*'"
    evaladvanced "git config --global merge.ff false"
}
function gitconfiguser() {
    $username = Read-Host "Username: "
    $email = Read-Host "Email: "
    evaladvanced "git config user.name `"$username`""
    evaladvanced "git config user.email `"$email`""
}
function gitcommit($commit) {
    git commit -m "$commit"
}
function gitstageall() {
    git add .
}
function gitstatus() {
    git status
}
