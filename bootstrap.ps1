#requires -Version 3
#using assembly System.Net.Http

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Make sure a correct trace information is displayed upon an unhandled exception
trap { throw $Error[0] }

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
Import-Module "${tmpArchiveBase}\Library\ImportModuleAsObject.psm1" -Force
$core = ImportModuleAsObject "${tmpArchiveBase}\Library\Core.psm1"
$mgmt = ImportModuleAsObject "${tmpArchiveBase}\Library\AppManagement.psm1"
$envutil = ImportModuleAsObject "${tmpArchiveBase}\Library\Env.psm1"
$git = ImportModuleAsObject "${tmpArchiveBase}\Apps\Git.psm1"

# Install chocolatey
if (-not (& $mgmt.ChocoIsChocoInstalled)) {
    Write-Host "Installing chocolatey ..."
    & $mgmt.ChocoInstallChoco
}

# Install git
if (-not (& $git.IsInstalled)) {
    Write-Host "Installing git ..."
    & $git.Install
}

# Clone the source into proper destination
$basedir = (& $core.GetBasePath)
#$basedir = "C:\Users\isojk\.wd_test"
if (Test-Path $basedir) {
    Write-Host "Deleting directory: ${basedir}"
    Remove-Item -Recurse -Force $basedir | Out-Null
}

git clone "$repositoryUrl" "$basedir"

# Refresh environment variables
& $envutil.RefreshEnvVars

# Jump to the entry script
& $basedir\wd.ps1 -FirstRun
