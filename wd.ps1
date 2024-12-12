[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\lib\apps.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\lib\core.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\lib\personal.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\lib\profile.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\lib\system.psm1 -Force -DisableNameChecking

$basedir = (wdCoreGetBasedir)
$data = (wdCoreGetDataDir)
$private = (wdCoreGetPrivateDataDir)

[Environment]::SetEnvironmentVariable("DOTFILES", "$data", "User")

$profile = wdLoadProfile "home"

#wdSystemConfigurePrivacy $profile
#wdSystemConfigureDefaultApps $profile
#wdSystemConfigureGeneral $profile
#wdSystemPostprocess $profile

#wdSystemPersonalizeGeneral $profile
#wdSystemPersonalizeExplorer $profile

#wdEvalProfileAppsConfig $profile
wdEvalProfileAppsConfig $profile -PersonalizeOnly
