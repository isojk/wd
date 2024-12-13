#using assembly System.Net.Http

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

$tmp = [System.IO.Path]::GetTempPath()
$tmpBase = "${tmp}/.wd"
$tmpArchiveFilename = "${tmpBase}/trunk.zip"
$tmpArchiveBasePart = "${tmpBase}/trunk"
$tmpArchiveBase = "${tmpArchiveBasePart}/wd-trunk"
$repositoryUrl = "https://github.com/isojk/wd"

# Download trunk archive from GitHub to user temporary directory

if (Test-Path $tmpBase) {
    Remove-Item -Recurse -Force $tmpBase | Out-Null
}

New-Item -ItemType Directory -Force -Path $tmpBase | Out-Null

Write-Host "Downloading temporary archive of the source ..."
Invoke-WebRequest "https://github.com/isojk/wd/archive/trunk.zip" -OutFile $tmpArchiveFilename
Expand-Archive $tmpArchiveFilename -DestinationPath $tmpArchiveBasePart

# Load essential modules

Import-Module $tmpArchiveBase\lib\core.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $tmpArchiveBase\lib\essentials.psm1 -Force -DisableNameChecking -Scope Local

# Install chocolatey

if ((wdChocoIsInstalled) -eq $false) {
    Write-Host "Installing chocolatey ..."
    wdChocoInstall
}

Import-Module "$(wdChocoGetInstallDir)\helpers\chocolateyProfile.psm1" -Force -DisableNameChecking -Scope Local

refreshenv

# Install git

if ((wdGitIsInstalled) -eq $false) {
    Write-Host "Installing git ..."
    wdGitInstall
    refreshenv
}

# Clone the source into proper destination

$basedir = wdCoreGetBasedir

if ((Test-Path $basedir) -eq $false) {
    git clone "$repositoryUrl" "$basedir"
}

# @TODO Call wd
