using assembly System.Net.Http

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

$IWR_TIMEOUT = 60 # seconds

# Generic domain

function wdGenericInstallFromURL {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $AppId,
        [Parameter(Mandatory = $true)] [string] $Url,
        [Parameter(Mandatory = $true)] [string] $Filename
    )

    process {
        $imTempDir = [System.IO.Path]::GetTempPath()
        $imTempFilename = "${imTempDir}/${Filename}"

        Write-Host "Downloading ${Filename} ..."

        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $Url -Out $imTempFilename -TimeoutSec $IWR_TIMEOUT

        $version = (Get-Item $imTempFilename).VersionInfo.ProductVersion
        Write-Host "Latest version: $version"

        $tmpbasedir = (wdCoreGetTempBasedir)
        $tmpdir = "${tmpbasedir}/generic_apps/${AppId}/${version}"
        if (-not (Test-Path $tmpdir)) {
            New-Item -ItemType Directory -Path $tmpdir | Out-Null
        }

        $tmpout = "${tmpdir}/${Filename}"
        Move-Item -Path $imTempFilename -Destination $tmpout -Force

        Write-Host "Executing ${Filename} ..."
        Start-Process -Wait $tmpout

        wdRefreshEnv

        Write-Host "Done"
    }
}

Export-ModuleMember -Function wdGenericInstallFromURL

# Choco

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

        wdRefreshEnv
    }
}

Export-ModuleMember -Function wdChocoInstall

function wdChocoInstallPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id,
        [Parameter(Mandatory = $false)] [string] $Params = $null
    )

    process {
        if ((wdChocoIsInstalled) -eq $false) {
            Write-Host -NoNewLine "Chocolatey must be installed first in order to install """
            Write-Host -NoNewLine -ForegroundColor Cyan "${Id}"
            Write-Host """"
            return
        }

        if (wdChocoIsPackageInstalled "${Id}") {
            Write-Host -NoNewLine """"
            Write-Host -NoNewLine -ForegroundColor Cyan "${Id}"
            Write-Host """ is already installed on this machine"
            return
        }

        if ($Params -ne $null -and $Params.Trim().Length -gt 0) {
            choco install -y "${Id}" --params "'$($Params.Trim())'"
        }
        else {
            choco install -y "${Id}"
        }

        wdRefreshEnv
    }
}

Export-ModuleMember -Function wdChocoInstallPackage

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
        if (wdGitIsInstalled) {
            wdCoreLog "git already installed on this machine using standalone installer"
            return
        }

        # https://github.com/chocolatey-community/chocolatey-packages/blob/master/automatic/git.install/ARGUMENTS.md
        wdChocoInstallPackage -Id "git.install" -Params "/GitOnlyOnPath /WindowsTerminal /NoShellIntegration /NoCredentialManager /SChannel /Editor:VisualStudioCode"
    }
}

Export-ModuleMember -Function wdGitInstall

#
# GitHub

function wdGithubDownloadLatestRelease {
    [CmdletBinding()]
    param(
        # "ungoogled-software/ungoogled-chromium-windows"
        [Parameter(Mandatory = $true)] [string] $Repository,

        # { $_.name.EndsWith("installer_x64.exe") }
        [Parameter(Mandatory = $true)] $AssetFilter
    )

    process {
        # https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3


        Write-Host -NoNewLine "Downloading latest release tag for """
        Write-Host -NoNewLine -ForegroundColor Cyan "${Repository}"
        Write-Host """ ..."

        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $tag = Invoke-WebRequest "https://api.github.com/repos/${Repository}/releases/latest" | ConvertFrom-Json
        $version = $tag.name

        Write-Host -NoNewLine "Latest release of """
        Write-Host -NoNewLine -ForegroundColor Cyan "${Repository}"
        Write-Host """ is: ${version}"

        Write-Host -NoNewLine "Filtering the correct asset for """
        Write-Host -NoNewLine -ForegroundColor Cyan "${Repository}"
        Write-Host """ ..."

        $asset = $tag.Assets | Where-Object $AssetFilter | Select -First 1
        if ($null -eq $asset) {
            Write-Error "Unable to find the correct asset file from the latest release"
        }

        $filename = $asset.name
        $downloadUrl = $asset.browser_download_url
        $tmpbasedir = (wdCoreGetTempBasedir)
        $tmpdir = "${tmpbasedir}/github_apps/${Repository}/${version}"
        if (-not (Test-Path $tmpdir)) {
            New-Item -ItemType Directory -Path $tmpdir | Out-Null
        }

        $tmpout = "${tmpdir}/${filename}"

        if (-not (Test-Path $tmpout)) {
            Write-Host "Downloading ${filename} ..."

            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest $downloadUrl -Out $tmpout -TimeoutSec $IWR_TIMEOUT
        }

        Write-Host "Executing ${filename} ..."
        Start-Process -Wait $tmpout

        wdRefreshEnv

        Write-Host "Done"
    }
}

Export-ModuleMember -Function wdGithubDownloadLatestRelease
