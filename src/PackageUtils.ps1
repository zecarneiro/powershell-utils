# Autor: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #


function InstallAllPackages() {
    InstallWinGet
    InstallScoop
    InstallChocolatey
    InstallMyPackages
}

# This function copied from the original: https://www.powershellgallery.com/packages/WingetTools/1.3.0
function InstallWinGet {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iwg")]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
        [switch]$Passthru
    )

    if (!(CommandExist -command "winget")) {
        LogLog "`nInstall Winget-CLI`n" -t "info"
        Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"

        if ($PSVersionTable.PSVersion.Major -eq 7) {
            Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
            return
        }

        #test for requirement
        $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
        if (-Not $requirement) {
            Write-Verbose "Installing Desktop App Installer requirement"
            Try {
                Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
            }
            Catch {
                Throw $_
            }
        }

        $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"

        Try {
            Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
            $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop

            Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
            #$data = $get | Select-Object -first 1
            $data = $get[0].assets | Where-Object name -Match 'msixbundle'

            $appx = $data.browser_download_url
            #$data.assets[0].browser_download_url
            Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
            If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
                $file = Join-Path -path $env:temp -ChildPath $data.name

                Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
                Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file

                Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
                Add-AppxPackage -Path $file -ErrorAction Stop

                if ($passthru) {
                    Get-AppxPackage microsoft.desktopAppInstaller
                }
            }
        } #Try
        Catch {
            Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
            Throw $_
        }
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
    }
    AddAlias -name "winget-upgrade" -command "winget upgrade --all"
    AddAlias -name "winget-uninstall" -command "winget uninstall --purge `$args"
    InstallBaseWingetPackage
}
function InstallBaseWingetPackage {
    if (!(CommandExist -command "git")) {
        LogLog "`nInstall Git - Set Add the Git Bash profile to Windows terminal"
        Eval -expression "winget install -i Git.Git"
    }
    AddAlias -name "git-bash" -command "& `"`$env:PROGRAMFILES\Git\bin\bash.exe`" `$args"
    AddAlias -name "git-repo-backup" -command "git clone --mirror `$args"
    AddAlias -name "git-repo-restore-backup" -command "git push --mirror `$args"
    if (!(CommandExist -command "gsudo")) {
        LogLog "`nInstall Gsudo - sudo"
        Eval -expression "winget install --id=gerardog.gsudo"
        Eval -expression "gsudo config CacheMode auto"
    }
    if (!(FileExist -file "C:\Users\nb26323\AppData\Local\Programs\Markdown Viewer\Markdown Viewer.exe")) {
        LogLog "`nInstall Markdown Viewer"
        Eval -expression "winget install -e --id c3er.mdview"
    }
}

function InstallScoop {
    if (!(CommandExist -command "scoop")) {
        LogLog "`nInstall Scoop"
        Eval -expression "irm get.scoop.sh | iex"
        Eval -expression "scoop bucket add main"
        Eval -expression "scoop bucket add extras"
    }
    AddAlias -name "scoop-clean" -command "scoop cleanup --all"
    AddAlias -name "scoop-upgrade" -command "scoop update --all"
    AddAlias -name "scoop-uninstall" -command "scoop uninstall --purge `$args"
    InstallBaseScoopPackage
}
function InstallBaseScoopPackage() {
    if (!(CommandExist -command "nano")) {
        LogLog "`nInstall nano"
        Eval -expression "scoop install main/nano"
    }
    if (!(CommandExist -command "sed")) {
        LogLog "`nInstall sed"
        Eval -expression "scoop install main/sed"
    }
    if (!(CommandExist -command "touch")) {
        LogLog "`nInstall touch"
        Eval -expression "scoop install main/touch"
    }
    if (!(CommandExist -command "grep")) {
        LogLog "`nInstall grep"
        Eval -expression "scoop install main/grep"
    }
    if (!(CommandExist -command "vim")) {
        LogLog "`nInstall vim"
        Eval -expression "scoop install main/vim"
    }
}

function InstallChocolatey() {
    if (!(CommandExist -command "choco")) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Download -URL "https://community.chocolatey.org/install.ps1" -File "$APPS_BIN_DIR\install.ps1"
        Eval -expression "sudo `"$APPS_BIN_DIR\install.ps1`""
        Eval -expression "rm `"$APPS_BIN_DIR\install.ps1`""
    }
}

function InstallMyPackages {
    InstallGo

    InfoLog "Install git-custom - Needs git"
    Compile -cmd "go build -o `"$APPS_BIN_DIR`" git-custom.go" -cwd "$APPS_GO_DIR"
    SetBinariesOnSystem "$APPS_BIN_DIR\git-custom.exe"

    InfoLog "Install directory-manager"
    Compile -cmd "go build -o `"$APPS_BIN_DIR`" directory-manager.go" -cwd "$APPS_GO_DIR"
    SetBinariesOnSystem "$APPS_BIN_DIR\directory-manager.exe"

    InfoLog "Install move-file-main-directory"
    Compile -cmd "go build -o `"$APPS_BIN_DIR`" move-file-main-directory.go" -cwd "$APPS_GO_DIR"
    SetBinariesOnSystem "$APPS_BIN_DIR\move-file-main-directory.exe"
}