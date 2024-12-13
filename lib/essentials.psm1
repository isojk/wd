using assembly System.Net.Http

Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

function wdChocoGetInstallDir {
    [CmdletBinding()]
    param()

    process {
        $dir = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "User")
        if ($dir -eq $null) {
            $dir = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine")
        }

        $dir
    }
}

Export-ModuleMember -Function wdChocoGetInstallDir

function wdChocoIsInstalled {
    [CmdletBinding()]
    param()

    process {
        $result = (wdCoreWhere choco) -ne $null
        if ($result -eq $false) {
            $dir = wdChocoGetInstallDir
            if ($dir -ne $null) {
                $result = (Test-Path $dir)
            }
        }

        $result
    }
}

Export-ModuleMember -Function wdChocoIsInstalled

function wdChocoIsPackageInstalled {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $id
    )

    process {
        (choco list --limit-output --id-only --exact $id) -ne $null
    }
}

Export-ModuleMember -Function wdChocoIsPackageInstalled

function wdChocoInstall {
    [CmdletBinding()]
    param()

    process {
        if (wdChocoIsInstalled) {
            wdCoreLogWarning "Chocolatey is already installed"
            return
        }

        $url = "https://community.chocolatey.org/install.ps1"

        $oldep = Get-ExecutionPolicy
        Set-ExecutionPolicy Bypass -Scope Process -Force

        $content = (New-Object System.Net.Http.HttpClient).GetStringAsync($url).GetAwaiter().GetResult()
        Invoke-Expression -Command $content

        Set-ExecutionPolicy $oldep -Scope Process -Force
    }
}

Export-ModuleMember -Function wdChocoInstall

function wdChocoInstallPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id
    )

    process {
        if ((wdChocoIsInstalled) -eq $false) {
            wdCoreLogWarning "Chocolatey must be installed first in order to install ${Id}"
            return
        }

        if (wdChocoIsPackageInstalled "${Id}") {
            wdCoreLog "${Id} is already installed on this machine"
            return
        }

        choco install -y "${Id}" #--params "'...'"
    }
}

function wdChocoUninstall {
    [CmdletBinding()]
    param()

    process {
        if ((wdChocoIsInstalled) -eq $false) {
            wdCoreLogWarning "Chocolatey not found on this machine"
            return
        }

        $dir = (wdChocoGetInstallDir)
        if ($dir -eq $null) {
            wdCoreLogWarning "Chocolatey installation path not found on this machine"
            return
        }

        [Environment]::SetEnvironmentVariable("ChocolateyInstall". $null, "User")
        [Environment]::SetEnvironmentVariable("ChocolateyInstall". $null, "Machine")
        [Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate". $null, "User")
        [Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate". $null, "Machine")

        Remove-Item -Recurse -Force $dir
    }
}

Export-ModuleMember -Function wdChocoUninstall


# Git

function wdGitIsInstalled {
    [CmdletBinding()]
    param()

    process {
        (wdCoreWhere git) -ne $null
    }
}

Export-ModuleMember -Function wdGitIsInstalled

function wdGitInstall {
    [CmdletBinding()]
    param()

    process {
        if ((wdChocoIsInstalled) -eq $false) {
            wdCoreLogWarning "Chocolatey must be installed first in order to install git"
            return
        }

        if (wdChocoIsPackageInstalled "git.install") {
            wdCoreLog "git already installed on this machine"
            return
        }

        if (wdGitIsInstalled) {
            wdCoreLog "git already installed on this machine using standalone installer"
            return
        }

        # https://github.com/chocolatey-community/chocolatey-packages/blob/master/automatic/git.install/ARGUMENTS.md
        choco install -y "git.install" --params "'/GitOnlyOnPath /WindowsTerminal /NoShellIntegration /NoCredentialManager /SChannel /Editor:VisualStudioCode'"
    }
}

Export-ModuleMember -Function wdGitInstall
