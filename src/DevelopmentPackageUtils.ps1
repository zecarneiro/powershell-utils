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
}

function install_node_typescript_javascript {
    if ((show_message_dev "NodeJS/Javascript/Typescript") -eq "y") {
        evaladvanced "winget install OpenJS.NodeJS.LTS"
        evaladvanced "npm install -g typescript"
    }
}

function install_python {
    if ((show_message_dev "Python3/PIP") -eq "y") {
        evaladvanced "scoop install main/python"
        evaladvanced "pip install virtualenv"
    }
}

function install_java {
    # To download executable go to: https://adoptopenjdk.net/ or https://adoptium.net/
    if ((show_message_dev "Java") -eq "y") {
        log "`nSet JAVA_HOME in option."
        evaladvanced "winget install -i AdoptOpenJDK.OpenJDK.11"
    }
}

function install_maven {
    if ((show_message_dev "Maven") -eq "y") {
        evaladvanced "scoop install main/maven"
    }
}

function install_cpp_c {
    if ((show_message_dev "C/C++/Make/CLang") -eq "y") {
        log "`nAdd PATH for LLVM and CMake"
        evaladvanced "scoop install make"
        evaladvanced "scoop install main/gcc"
        evaladvanced "scoop install cmake"
        evaladvanced "scoop install clangd"
    }
}

function install_php {
    if ((show_message_dev "PHP") -eq "y") {
        evaladvanced "scoop install php"
    }
}

function install_golang {
    if ((show_message_dev "Go") -eq "y") {
        $executable = "$APPS_BIN_DIR\go1.20.5.windows-amd64.msi"
        download -url "https://go.dev/dl/go1.20.5.windows-amd64.msi" -file "$executable"
        evaladvanced "Start-Process $executable"
        evaladvanced "rm $executable"
    }
}

function install_sqlite3 {
    if ((show_message_dev "Sqlite3") -eq "y") {
        infolog "`nDownload link example: https://www.sqlite.org/2022/sqlite-tools-win32-x86-{version}.zip"
        evaladvanced "scoop install sqlite"
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
