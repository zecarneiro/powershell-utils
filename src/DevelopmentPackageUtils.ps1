# Author: José M. C. Noronha

function show_message_dev {
    param([string] $message)
    $userInput = (read_user_keyboard "Do you want to install ${message}? (y/N)")
    return $userInput
}

function install_development_package {
    install_node_typescript_javascript
    install_python
    install_java
    install_maven
    install_cpp_c
    install_php
    install_golang
    install_sqlite3
    install_postgres_sql
    install_shell_check
}

function install_node_typescript_javascript {
    if ((show_message_dev "NodeJS/Javascript/Typescript") -eq "y") {
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/nodejs-lts"
        . reloadprofile
        evaladvanced "npm install -g typescript"
    }
}

function install_python {
    if ((show_message_dev "Python3/PIP") -eq "y") {
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/python"
        evaladvanced "pip install virtualenv"
    }
}

function install_java {
    $message = "`nSet JAVA_HOME in option."
    # To download executable go to: https://adoptopenjdk.net/ or https://adoptium.net/
    if ((show_message_dev "Java JDK 17") -eq "y") {
        log "$message"
        evaladvanced "winget install -i --id=EclipseAdoptium.Temurin.17.JDK"
    }
    if ((show_message_dev "Java JDK 11") -eq "y") {
        log "$message"
        evaladvanced "winget install -i --id=EclipseAdoptium.Temurin.11.JDK"
    }
}

function install_maven {
    if ((show_message_dev "Maven") -eq "y") {
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/maven"
    }
}

function install_cpp_c {
    if ((show_message_dev "C/C++/Make/CLang") -eq "y") {
        log "`nAdd PATH for LLVM and CMake"
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/make"
        evaladvanced "scoop install main/gcc"
        evaladvanced "scoop install main/cmake"
        evaladvanced "scoop install main/clangd"
    }
}

function install_php {
    if ((show_message_dev "PHP") -eq "y") {
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/php"
    }
}

function install_golang {
    if ((show_message_dev "Go") -eq "y") {
        evaladvanced "scoop bucket add main"
        evaladvanced "scoop install main/go"
        . reloadprofile
        evaladvanced "go install golang.org/x/tools/gopls@latest"
        addalias "goclean" -command "go clean -cache -modcache -testcache -fuzzcache"
    }
}

function install_sqlite3 {
    if ((show_message_dev "Sqlite3") -eq "y") {
        infolog "`nDownload link example: https://www.sqlite.org/2022/sqlite-tools-win32-x86-{version}.zip"
        evaladvanced "winget install --id=SQLite.SQLite"
    }
}

function install_postgres_sql {
    if ((show_message_dev "Postgres SQL") -eq "y") {
        infolog "`nDownload link example: https://www.sqlite.org/2022/sqlite-tools-win32-x86-{version}.zip"
        infolog "For Client only only keep the options: Command line Tools"
        evaladvanced "winget install -i --id=PostgreSQL.PostgreSQL"
        & "$IMAGE_UTILS_DIR\postgressql.png"
    }
}

function install_shell_check {
    if ((show_message_dev "Shellcheck") -eq "y") {
        evaladvanced "scoop install shellcheck"
    }
}
