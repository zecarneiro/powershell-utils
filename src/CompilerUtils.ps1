function Compile {
    param (
        [string] $cmd,
        [string] $cwd
    )
    $currentDir = "$pwd"
    InfoLog -message "Compiling..."
    cd "$cwd"
    Eval -expression "$cmd"
    cd "$currentDir"
}