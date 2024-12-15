#using assembly System.Net.Http

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

# Make sure this script is run with administrator privileges
$currentPrincipal = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()))
if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Error "You must execute this script with administrator privileges"
    exit 1
}

$tmp = [System.IO.Path]::GetTempPath()
$tmpBase = "${tmp}/.wd"

$branch = "trunk"
$repositoryUrl = "https://github.com/isojk/wd"

$tmpArchiveFilename = "${tmpBase}/${branch}.zip"
$tmpArchiveBasePart = "${tmpBase}/${branch}"
$tmpArchiveBase = "${tmpArchiveBasePart}/wd-${branch}"

# Download trunk archive from GitHub to user temporary directory

if (-not (Test-Path $tmpBase)) {
    New-Item -ItemType Directory -Force -Path $tmpBase | Out-Null
}

if (Test-Path $tmpArchiveFilename) {
    Remove-Item -Force $tmpArchiveFilename | Out-Null
}

Write-Host "Downloading temporary archive of the source ..."
Invoke-WebRequest "${repositoryUrl}/archive/${branch}.zip" -OutFile $tmpArchiveFilename

if (Test-Path $tmpArchiveBasePart) {
    Remove-Item -Recurse -Force $tmpArchiveBasePart | Out-Null
}

Expand-Archive $tmpArchiveFilename -DestinationPath $tmpArchiveBasePart

# Load essential modules

Import-Module $tmpArchiveBase/lib/core.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $tmpArchiveBase/lib/essentials.psm1 -Force -DisableNameChecking -Scope Local

# Install chocolatey

if (-not (wdChocoIsInstalled)) {
    Write-Host "Installing chocolatey ..."
    wdChocoInstall
}

# Install git

if (-not (wdGitIsInstalled)) {
    Write-Host "Installing git ..."
    wdGitInstall
}

# Clone the source into proper destination

$basedir = wdCoreGetBasedir

if (Test-Path $basedir) {
    Write-Host "Deleting directory: ${basedir}"
    Remove-Item -Recurse -Force $basedir | Out-Null
}

git clone "$repositoryUrl" "$basedir"

wdCoreEnsureEnvironmentVars

& $basedir\wd.ps1 -FirstRun
