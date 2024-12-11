[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\core.psm1

#$PSModuleAutoLoadingPreference = "All"

$appInstallationHandlers = @{}
$appPersonalizationHandlers = @{}

$appModules = Get-Module -Name "${PSScriptRoot}\apps\*.psm1" -ListAvailable
foreach ($appModule in $appModules) {
    Import-Module $appModule -Force
    $appId = "$($appModule.Name)"
    #Write-Host $appId

    $appInstallationHandler = Get-Command -Module $appModule | Where-Object {$_.Name -eq "atn_install_${appId}"} | Select -First 1
    if ($appInstallationHandler -ne $null) {
        $appInstallationHandlers[$appId] = $appInstallationHandler
    }

    $appPersonalizationHandler = Get-Command -Module $appModule | Where-Object {$_.Name -eq "atn_personalize_${appId}"} | Select -First 1
    if ($appPersonalizationHandler -ne $null) {
        $appPersonalizationHandlers[$appId] = $appPersonalizationHandler
    }
}

function atn_install_application ($appId, $profile) {
    if (-not $appInstallationHandlers.Contains($appId)) {
        atn_core_log_warning "Installation routine for ${appId} does not exist"
        return
    }

    $handler = $appInstallationHandlers[$appId]
    atn_core_log "Installing ${appId} ..."

    & $handler $profile
}

Export-ModuleMember -Function atn_install_application

function atn_personalize_application ($appId, $profile) {
    if (-not $appPersonalizationHandlers.Contains($appId)) {
        atn_core_log_warning "Personalization routine for ${appId} does not exist"
        return
    }

    $handler = $appPersonalizationHandlers[$appId]
    atn_core_log "Personalizing ${appId} ..."

    & $handler $profile
}

Export-ModuleMember -Function atn_personalize_application

function atn_eval_profile_apps {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [object] $profile,
        [Parameter(Mandatory = $false)] [switch] $PersonalizeOnly = $false
    )

    $list = $profile."Rules"."Applications"
    if ($list -eq $null) {
        atn_core_log "Profile does not have rules for: Applications"
        return
    }

    foreach ($listprop in $list.PSObject.Properties) {
        $appId = $listprop.Name
        $rule = $listprop.Value

        if ($rule -is [string]) {
            $rule = $rule.Trim().ToLower()
        }

        if ($rule -eq "install_full") {
            if ($PersonalizeOnly -eq $false) {
                atn_install_application $appId $profile
            }

            atn_personalize_application $appId $profile
        }
    }
}

Export-ModuleMember -Function atn_eval_profile_apps
