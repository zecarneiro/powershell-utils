function ShowMessageDev {
    param([string] $message)
    $userInput = (ReadUserKeyboard -message "Do you want to install ${message}? (y/N)")
    return $userInput
}

function InstallDevelopmentPackage {
    InstallNodeTypescriptJavascript
    InstallPython
    InstallJava
    InstallMaven
    InstallCppC
    InstallPhp
    InstallGo
    InstallSqlite3
    InstallPostgresSql
}

function InstallNodeTypescriptJavascript {
    if ((ShowMessageDev -message "NodeJS/Javascript/Typescript") -eq "y") {
        Eval -expression "winget install OpenJS.NodeJS.LTS"
        Eval -expression "npm install -g typescript"
    }
    AddAlias -name "npm-upgrade" -command "npm outdated -g; npm update -g"
}

function InstallPython {
    if ((ShowMessageDev -message "Python3/PIP") -eq "y") {
        Eval -expression "scoop install main/python"
        Eval -expression "pip install virtualenv"
    }
}

function InstallJava {
    # To download executable go to: https://adoptopenjdk.net/ or https://adoptium.net/
    if ((ShowMessageDev -message "Java") -eq "y") {
        LogLog "`nSet JAVA_HOME in option."
        Eval -expression "winget install -i AdoptOpenJDK.OpenJDK.11"
    }
}

function InstallMaven {
    if ((ShowMessageDev -message "Maven") -eq "y") {
        Eval -expression "scoop install main/maven"
    }
}

function InstallCppC {
    if ((ShowMessageDev -message "C/C++/Make/CLang") -eq "y") {
        LogLog "`nAdd PATH for LLVM and CMake"
        Eval -expression "scoop install make"
        Eval -expression "scoop install main/gcc"
        Eval -expression "scoop install cmake"
        Eval -expression "scoop install clangd"
    }
}

function InstallPhp {
    if ((ShowMessageDev -message "PHP") -eq "y") {
        Eval -expression "scoop install php"
    }
}

function InstallGo {
    if ((ShowMessageDev -message "Go") -eq "y") {
        $executable = "$APPS_BIN_DIR\go1.20.5.windows-amd64.msi"
        Download -URL "https://go.dev/dl/go1.20.5.windows-amd64.msi" -File "$executable"
        Eval -expression "Start-Process $executable"
        Eval -expression "rm $executable"
    }
}

function InstallSqlite3 {
    if ((ShowMessageDev -message "Sqlite3") -eq "y") {
        InfoLog "`nDownload link example: https://www.sqlite.org/2022/sqlite-tools-win32-x86-{version}.zip"
        Eval -expression "scoop install sqlite"
    }
}

function InstallPostgresSql {
    if ((ShowMessageDev -message "Postgres SQL") -eq "y") {
        InfoLog "`nDownload link example: https://www.sqlite.org/2022/sqlite-tools-win32-x86-{version}.zip"
        InfoLog "For Client only only keep the options: Command line Tools"
        Eval -expression "winget install -i --id=PostgreSQL.PostgreSQL"
        & "$IMAGE_UTILS_DIR\postgressql.png"
    }
}

