# Author: José M. C. Noronha

# ---------------------------------------------------------------------------- #
#                                   FUNCTIONS                                  #
# ---------------------------------------------------------------------------- #
function install_all_packages() {
    install_winget
    install_scoop
}

function install_all_base_packages() {
    install_base_winget_package
    install_base_scoop_package
}

# ---------------------------------------------------------------------------- #
#                                 PACKAGES AREA                                #
# ---------------------------------------------------------------------------- #
# This function copied from the original: https://www.powershellgallery.com/packages/WingetTools/1.3.0
function install_winget {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iwg")]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
        [switch]$Passthru
    )

    if (!(commandexists "winget") -or (confirm "Winget is already installed, would you like to update it")) {
        infolog "Install Winget-CLI"
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
}

function install_scoop {
    if (!(commandexists -command "scoop")) {
        log "`nInstall Scoop"
        evaladvanced "irm get.scoop.sh | iex"
    }
}

# ---------------------------------------------------------------------------- #
#                              BASE PACKAGES AREA                              #
# ---------------------------------------------------------------------------- #
function install_base_winget_package {
    if (!(commandexists -command "git")) {
        log "`nInstall Git - Set Add the Git Bash profile to Windows terminal"
        evaladvanced "winget install -i --id=Git.Git"
    }
    $app = (wingetlist "c3er.mdview")
    if (![string]::IsNullOrEmpty($app) -or !$app -contains "c3er.mdview") {
        $commandMd = "$home\.local\bin\mdview.ps1"
        log "`nInstall Markdown Viewer"
        evaladvanced "winget install --id=c3er.mdview"
        writefile "$commandMd" "& '$home\AppData\Local\Programs\Markdown Viewer\mdview.exe' ```$args"
    }
    $app = (wingetlist "vim.vim")
    if ([string]::IsNullOrEmpty($app) -or !$app -contains "vim.vim") {
        log "`nInstall vim"
        evaladvanced "winget install --id=vim.vim"
    }
    $app = (wingetlist "GNU.Nano")
    if ([string]::IsNullOrEmpty($app) -or !$app -contains "GNU.Nano") {
        log "`nInstall nano"
        evaladvanced "winget install --id=GNU.Nano"
    }
}

function install_base_scoop_package() {
    evaladvanced "scoop install git"
    evaladvanced "scoop bucket add main"
    evaladvanced "scoop bucket add extras"
    if (!(commandexists -command "gsudo")) {
        $profilePowershell = $PROFILE.CurrentUserAllHosts
        log "`nInstall Gsudo - sudo"
        evaladvanced "scoop install gsudo"
        . reloadprofile
        evaladvanced "gsudo config CacheMode auto"
        writefile "$profilePowershell" "Import-Module `"gsudoModule`"" -append
        addalias -name "su" -command "sudo"
        addalias -name "sudoshell" -command "sudo powershell.exe" -passArgs
    }
}
