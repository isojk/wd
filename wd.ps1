[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param(
    [Parameter(Mandatory = $false)] [string]    $Profile = $null,

    [Parameter(Mandatory = $false)] [switch]    $FirstRun = $false,

    [Parameter(Mandatory = $false)] [switch]    $System = $false,
    [Parameter(Mandatory = $false)] [switch]    $All = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigureAll = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigurePrivacy = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigureDefaultApps = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigureGeneral = $false,
    [Parameter(Mandatory = $false)] [switch]    $PersonalizeAll = $false,
    [Parameter(Mandatory = $false)] [switch]    $Personalize = $false,
    [Parameter(Mandatory = $false)] [switch]    $PersonalizeExplorer = $false,

    [Parameter(Mandatory = $false)] [switch]    $FullAppSetup = $false,
    [Parameter(Mandatory = $false)] [switch]    $InstallOnly = $false,
    [Parameter(Mandatory = $false)] [switch]    $ConfigureOnly = $false,
    [Parameter(Mandatory = $false)] [int]       $CfgLevel = 1,
    [Parameter(Mandatory = $false)] [switch]    $AllApps = $false,
    [Parameter(Mandatory = $false)] [string]    $App = $null,

    [Parameter(Mandatory = $false)] [switch]    $EnumEnvVars = $false,
    [Parameter(Mandatory = $false)] [switch]    $EnumEnvPath = $false,
    [Parameter(Mandatory = $false)] [string]    $EnvTarget = "User",

    [Parameter(Mandatory = $false)] [string]    $Where = $null
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

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

    $response = (wdConAskYesNo -Prompt "Do you want to install and configure all appications now?" -DefaultValue "yes")
    if ($response -eq "yes") {
        wdHandleAllProfileApps -Profile $profileData -Install $true -Configure $true -CfgLevel 99
        wdCoreLog "Done"
    }

    exit 0
}

#
# System configuration
#

if ($System) {
    $doConfigurePrivacy = ($All -or $ConfigureAll -or $ConfigurePrivacy)
    $doConfigureDefaultApps = ($All -or $ConfigureAll -or $ConfigureDefaultApps)
    $doConfigureGeneral = ($All -or $ConfigureAll -or $ConfigureGeneral)

    $doPersonalizeGeneral = ($All -or $PersonalizeAll -or $Personalize)
    $doPersonalizeExplorer = ($All -or $PersonalizeAll -or $PersonalizeExplorer)

    $steps = 0

    if ($doConfigurePrivacy) {
        $steps += 1
    }

    if ($doConfigureDefaultApps) {
        $steps += 1
    }

    if ($doConfigureGeneral) {
        $steps += 1
    }

    if ($doPersonalizeGeneral) {
        $steps += 1
    }

    if ($doPersonalizeExplorer) {
        $steps += 1
    }

    if ($doConfigurePrivacy -and (wdConAskYesNo -Prompt "Do you want to configure system privacy options?" -DefaultValue "yes") -eq "yes") {
        $hasAny = $true
        wdSystemConfigurePrivacy -profile $profileData
    }

    if ($doConfigureDefaultApps -and (wdConAskYesNo -Prompt "Do you want to configure default applications?" -DefaultValue "yes") -eq "yes") {
        $hasAny = $true
        wdSystemConfigurePrivacy -profile $profileData
    }

    if ($doConfigureGeneral -and (wdConAskYesNo -Prompt "Do you want to configure system general options?" -DefaultValue "yes") -eq "yes") {
        $hasAny = $true
        wdSystemConfigureGeneral -profile $profileData
    }

    if ($doPersonalizeGeneral -and (wdConAskYesNo -Prompt "Do you want to personalize system now?" -DefaultValue "yes") -eq "yes") {
        $hasAny = $true
        wdSystemPersonalizeGeneral -profile $profileData
    }

    if ($doPersonalizeExplorer -and (wdConAskYesNo -Prompt "Do you want to personalize windows explorer now?" -DefaultValue "yes") -eq "yes") {
        $hasAny = $true
        wdSystemPersonalizeExplorer -profile $profileData
    }

    if ($steps -gt 0) {
        wdSystemPostprocess -profile $profileData
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
        if ((wdConAskYesNo -Prompt "Do you want to (re-)install and configure all applications? (Configuration level ${CfgLevel})" -DefaultValue "yes") -eq "yes") {
            wdHandleAllProfileApps -Profile $profileData -Install $doInstall -Configure $doConfigure -CfgLevel $CfgLevel -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
        }
    }
    else {
        if ($doInstall) {
            if ((wdConAskYesNo -Prompt "Do you want to (re-)install ""${appId}""?" -DefaultValue "yes") -eq "yes") {
                wdInstallApplication -AppId $appId -Profile $profileData -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
            }
        }

        if ($doConfigure) {
            if ((wdConAskYesNo -Prompt "Do you want to configure ""${appId}""? (Configuration level ${CfgLevel})" -DefaultValue "yes") -eq "yes") {
                wdConfigureApplication -AppId $appId -Profile $profileData -Level $CfgLevel -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
            }
        }
    }

    wdSystemPostprocess -profile $profileData

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

if ($Where.Trim().Length -gt 0) {
    wdCoreWhere $Where
    exit 0
}


#
# Print help

if ($true) {
    Write-Host "Usage:"
    Write-Host "Run all scripts related to system setup:"
    Write-Host "wd -Profile home -System -All"
    Write-Host
    Write-Host "Run all scripts related to privacy configuration:"
    Write-Host "wd -Profile home -System -ConfigurePrivacy"
    Write-Host
    Write-Host "Run all scripts for full configuration and for personalizing explorer:"
    Write-Host "wd -Profile home -System -ConfigureAll -PersonalizeExplorer"
    Write-Host
    Write-Host "Install and configure all apps defined in the selected profile:"
    Write-Host "(-CfgLevel determines, if supported, the extent of the configuration step. 1 is lowest, 99 is highest.)"
    Write-Host "wd -Profile home -FullAppSetup -AllApps [-CfgLevel]"
    Write-Host
    Write-Host "Configure only specific app:"
    Write-Host "(vscode will (re-)install extensions only with -CfgLevel being set 2 or higher)"
    Write-Host "wd -Profile home -ConfigureOnly -CfgLevel 2 -App vscode"
    Write-Host
    Write-Host "Print all user environment variables:"
    Write-Host "(For -EnvTarget option, ""User"" and ""Machine"" values are supported)"
    Write-Host "wd -EnumEnvVars"
    Write-Host
    Write-Host "Print all directories stored in this machine PATH environment variable"
    Write-Host "wd -EnumEnvPath -EnvTarget Machine"
    Write-Host
}
