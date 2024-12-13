#using assembly System.Net.Http

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

$tmpBase = "${Env:TEMP}/.wd"
$tmpArchiveFilename = "${tmpBase}/trunk.zip"
$tmpArchiveBasePart = "${tmpBase}/trunk"
$tmpArchiveBase = "${tmpArchiveBasePart}/wd-trunk"
$repositoryUrl = "https://github.com/isojk/wd"

# Download trunk archive from GitHub to user temporary directory

if (Test-Path $tmpBase) {
    Remove-Item -Recurse -Force $tmpBase
}

New-Item -ItemType Directory -Force -Path $tmpBase

Write-Host "Downloading temporary archive of the source ..."
Invoke-WebRequest "https://github.com/isojk/wd/archive/trunk.zip" -OutFile $tmpArchiveFilename
Expand-Archive $tmpArchiveFilename -DestinationPath $tmpArchiveBasePart

# Load essential modules

Import-Module $tmpArchiveBase\lib\core.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $tmpArchiveBase\lib\essentials.psm1 -Force -DisableNameChecking -Scope Local

# Install chocolatey

if (wdChocoIsInstalled -eq $false) {
    Write-Host "Installing chocolatey ..."
    wdChocoInstall
}

# Install git

if (wdGitIsInstalled -eq $false) {
    Write-Host "Installing git ..."
    wdGitInstall
}

# Clone the source into proper destination

$basedir = wdCoreGetBasedir
git clone "$repositoryUrl" "$basedir"

