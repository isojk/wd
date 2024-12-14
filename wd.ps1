[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

$ErrorActionPreference = "Stop"

# Make sure this script is run with administrator privileges
$currentPrincipal = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()))
if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Error "You must execute this script with administrator privileges"
    exit 1
}

Import-Module $PSScriptRoot\lib\apps.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\core.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\essentials.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\personal.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\profile.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\system.psm1 -Force -DisableNameChecking -Scope Local

#
# 
#

$basedir = (wdCoreGetBasedir)
$data = (wdCoreGetDataDir)
$private = (wdCoreGetPrivateDataDir)

Write-Host "`$data: ${data}"

[Environment]::SetEnvironmentVariable("DOTFILES", "$data", "User")

$profile = wdLoadProfile "home"

#wdSystemConfigurePrivacy $profile
#wdSystemConfigureDefaultApps $profile
#wdSystemConfigureGeneral $profile
#wdSystemPostprocess $profile

#wdSystemPersonalizeGeneral $profile
#wdSystemPersonalizeExplorer $profile

#wdEvalProfileAppsConfig $profile
#wdEvalProfileAppsConfig $profile -PersonalizeOnly
