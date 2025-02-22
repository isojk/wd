using assembly System.Net.Http

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\ImportModuleAsObject.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\Console.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\Core.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\Env.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\Logger.psm1"


$IWR_TIMEOUT = 60 # seconds

function DownloadFromURLAndInstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $AppId,
        [Parameter(Mandatory = $true)] [string] $Url,
        [Parameter(Mandatory = $true)] [string] $Filename
    )

    process {
        $imTempDir = [System.IO.Path]::GetTempPath()
        $imTempFilename = "${imTempDir}/${Filename}"

        & $logger.Log "Downloading {0} ..." $Filename

        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $Url -Out $imTempFilename -TimeoutSec $IWR_TIMEOUT

        $version = (Get-Item $imTempFilename).VersionInfo.ProductVersion
        & $logger.Log "Latest version: {0}" $version

        $tmpbasedir = (& $core.GetTempPath)
        $tmpdir = "${tmpbasedir}/generic/${AppId}/${version}"
        if (-not (Test-Path $tmpdir)) {
            New-Item -ItemType Directory -Path $tmpdir | Out-Null
        }

        $tmpout = "${tmpdir}/${Filename}"
        Move-Item -Path $imTempFilename -Destination $tmpout -Force

        & $logger.Log "Executing {0} ..." $Filename
        Start-Process -Wait $tmpout

        & $envutil.RefreshEnvVars

        & $logger.Log "Done"
    }
}

Export-ModuleMember -Function DownloadFromURLAndInstall

function ChocoIsChocoInstalled {
    [CmdletBinding()]
    param()

    process {
        $result = (& $core.WhereIs choco) -ne $null
        if ($result -eq $false) {
            $dir = (& ChocoGetInstallationDir)
            if ($dir -ne $null) {
                $result = (Test-Path $dir)
            }
        }

        $result
    }
}

Export-ModuleMember -Function ChocoIsChocoInstalled

function ChocoIsPackageInstalled {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $id
    )

    process {
        (choco list --limit-output --id-only --exact $id) -ne $null
    }
}

Export-ModuleMember -Function ChocoIsPackageInstalled

function ChocoInstallChoco {
    [CmdletBinding()]
    param()

    process {
        if (& ChocoIsChocoInstalled) {
            & $core.LogWarning "Chocolatey is already installed"
            return
        }

        $url = "https://community.chocolatey.org/install.ps1"

        $oldep = Get-ExecutionPolicy
        Set-ExecutionPolicy Bypass -Scope Process -Force

        $content = (New-Object "System.Net.Http.HttpClient").GetStringAsync($url).GetAwaiter().GetResult()
        Invoke-Expression -Command $content

        Set-ExecutionPolicy $oldep -Scope Process -Force

        & $envutil.RefreshEnvVars
    }
}

Export-ModuleMember -Function ChocoInstallChoco

function ChocoInstallPackage {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id,
        [Parameter(Mandatory = $false)] [string] $Params = $null,
        [Parameter(Mandatory = $false)] [bool] $Force = $false
    )

    process {
        if ((& ChocoIsChocoInstalled) -eq $false) {
            & $logger.LogWarning "Chocolatey must be installed first in order to install ""{0}""" $Id
            return
        }

        if (& ChocoIsPackageInstalled $Id) {
            & $logger.LogWarning """{0}"" is already installed on this machine" $Id
            return
        }

        # @TODO
        if ($Params -ne $null -and $Params.Trim().Length -gt 0) {
            if ($Force) {
                & choco install --no-progress -y "${Id}" --params "'$($Params.Trim())'" --force | Write-Host
            }
            else {
                & choco install --no-progress -y "${Id}" --params "'$($Params.Trim())'" | Write-Host
            }
        }
        else {
            if ($Force) {
                & choco install --no-progress -y "${Id}" --force | Write-Host
            }
            else {
                & choco install --no-progress -y "${Id}" | Write-Host
            }
        }

        & $envutil.RefreshEnvVars
    }
}

Export-ModuleMember -Function ChocoInstallPackage

function ChocoUninstallChoco {
    [CmdletBinding()]
    param()

    process {
        if ((& ChocoIsChocoInstalled) -eq $false) {
            & $logger.LogWarning "Chocolatey not found on this machine"
            return
        }

        $dir = (& ChocoGetInstallationDir)
        if ($dir -eq $null) {
            & $logger.LogWarning "Chocolatey installation path not found on this machine"
            return
        }

        [Environment]::SetEnvironmentVariable("ChocolateyInstall". $null, "User")
        [Environment]::SetEnvironmentVariable("ChocolateyInstall". $null, "Machine")
        [Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate". $null, "User")
        [Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate". $null, "Machine")

        Remove-Item -Recurse -Force $dir
    }
}

Export-ModuleMember -Function ChocoUninstallChoco

function GithubDownloadLatestRelease {
    [CmdletBinding()]
    param(
        # "ungoogled-software/ungoogled-chromium-windows"
        [Parameter(Mandatory = $true)] [string] $Repository,

        # { $_.name.EndsWith("installer_x64.exe") }
        [Parameter(Mandatory = $true)] [ScriptBlock] $AssetFilter
    )

    process {
        # https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3

        & $logger.Log "Downloading latest release tag for ""{0}"" ..." $Repository

        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $tag = Invoke-WebRequest "https://api.github.com/repos/${Repository}/releases/latest" | ConvertFrom-Json
        $version = $tag.name

        Write-Host -NoNewLine "Latest release of ""{0}"" is: {1}" $Repository $version

        Write-Host -NoNewLine "Filtering the correct asset for ""{0}"" ..." $Repository

        $asset = $tag.Assets | Where-Object $AssetFilter | Select -First 1
        if ($null -eq $asset) {
            Write-Error "Unable to find the correct asset file from the latest release of ""${Repository}"" (${version})"
        }

        $filename = $asset.name
        $downloadUrl = $asset.browser_download_url
        $tmpbasedir = (& $core.GetTempPath)
        $tmpdir = "${tmpbasedir}/github_apps/${Repository}/${version}"
        if (-not (Test-Path $tmpdir)) {
            New-Item -ItemType Directory -Path $tmpdir | Out-Null
        }

        $tmpout = "${tmpdir}/${filename}"

        if (-not (Test-Path $tmpout)) {
            & $logger.Log "Downloading ${filename} ..."

            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest $downloadUrl -Out $tmpout -TimeoutSec $IWR_TIMEOUT
        }

        & $logger.Log "Executing ${filename} ..."
        Start-Process -Wait $tmpout

        & $envutil.RefreshEnvVars
        & $logger.Log "Done"
    }
}

Export-ModuleMember -Function GithubDownloadLatestRelease
