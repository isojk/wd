[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param(
    [Parameter(Mandatory = $false)] [string]    $Profile = $null,
    [Parameter(Mandatory = $false)] [switch]    $FullAppSetup = $false,
    [Parameter(Mandatory = $false)] [switch]    $InstallOnly = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigureOnly = $false,
    [Parameter(Mandatory = $false)] [int]       $CfgLevel = 1,
    [Parameter(Mandatory = $false)] [switch]    $AllApps = $false,
    [Parameter(Mandatory = $false)] [string]    $App = $null,
    [Parameter(Mandatory = $false)] [switch]    $FirstRun = $false,
    [Parameter(Mandatory = $false)] [switch]    $EnumEnvVars = $false,
    [Parameter(Mandatory = $false)] [switch]    $EnumEnvPath = $false,
    [Parameter(Mandatory = $false)] [string]    $EnvTarget = "User"
)

$ErrorActionPreference = "Stop"

# Make sure this script is run with administrator privileges
$currentPrincipal = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()))
if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Error "You must execute this script with administrator privileges"
    exit 1
}

Import-Module $PSScriptRoot\lib\apps.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\conutil.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\core.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\essentials.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\personal.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\profile.psm1 -Force -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\lib\system.psm1 -Force -DisableNameChecking -Scope Local

wdCoreEnsureEnvironmentVars

#
# 
#

# https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-null?view=powershell-7.4#in-strings
if ($Profile.Trim().Length -eq 0) {
    $Profile = "default"
}

# Load profile
#wdCoreLog "Loading profile '${Profile}'"
$profileData = wdLoadProfile $Profile

#
# Used in conjunction with the bootstrap script
#

if ($FirstRun) {
    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""privacy configuration"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemConfigurePrivacy $profileData
        wdCoreLog "Done"
    }

    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""default applications"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemConfigureDefaultApps $profileData
        wdCoreLog "Done"
    }

    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""general configuration"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemConfigureGeneral $profileData
        wdCoreLog "Done"
    }

    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""general personalization"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemPersonalizeGeneral $profileData
        wdCoreLog "Done"
    }

    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""explorer personalization"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemPersonalizeExplorer $profileData
        wdCoreLog "Done"
    }

    $response = (wdConAskYesNo -Prompt "Do you want to apply system ""post-process"" rules now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdSystemPostprocess $profileData
        wdCoreLog "Done"
    }

    exit 0
}

#
# Invoke actions for applications
#

if ($FullAppSetup -or $InstallOnly -or $ConfigureOnly) {
    if (-not ($AllApps -or $App.Trim().Length -gt 0)) {
        wdCoreLogWarning "Set either -AllApps to include all applications, or specify single application using -Application"
        exit 0
    }

    $doInstall = ($FullAppSetup -or $InstallOnly)
    $doConfigure = ($FullAppSetup -or $ConfigureOnly)

    $appInstallationHandlers = @{}
    $appPersonalizationHandlers = @{}

    $appId = $App.Trim().ToLower()

    $profileEval = (wdEvalProfileAppsConfig -Profile $profiledata -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers -SpecificAppId $appId)
    if (-not ($profileEval)) {
        return
    }

    if ($AllApps) {
        wdHandleAllProfileApps -Profile $profileData -Install $doInstall -Configure $doConfigure -CfgLevel $CfgLevel -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
        exit 0
    }

    if ($doInstall) {
        wdInstallApplication -AppId $appId -Profile $profileData -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
    }

    if ($doConfigure) {
        wdConfigureApplication -AppId $appId -Profile $profileData -Level $CfgLevel -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
    }

    exit 0
}


#
# Environment variable utility

if ($EnumEnvVars) {
    wdCoreEnumEnvVars -Target $EnvTarget
    exit 0
}

if ($EnumEnvPath) {
    wdCoreEnumEnvPath -Target $EnvTarget -Sort
    exit 0
}
