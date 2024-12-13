Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

#$PSModuleAutoLoadingPreference = "All"

function wdInstallApplication {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $appId,
        [Parameter(Position = 1, Mandatory = $true)] [object] $profile
    )

    process {
        if (-not $appInstallationHandlers.Contains($appId)) {
            wdCoreLogWarning "Installation routine for ${appId} does not exist"
            return
        }

        $handler = $appInstallationHandlers[$appId]
        wdCoreLog "Installing ${appId} ..."

        & $handler $profile
    }
}

Export-ModuleMember -Function wdInstallApplication

function wdPersonalizeApplication {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $AppID,
        [Parameter(Position = 1, Mandatory = $true)] [object] $Profile,
        [Parameter(Mandatory = $false)] [int] $Level = 1
    )

    process {
        if (-not $appPersonalizationHandlers.Contains($AppID)) {
            wdCoreLogWarning "Personalization routine for ${AppID} does not exist"
            return
        }

        $handler = $appPersonalizationHandlers[$AppID]
        wdCoreLog "Personalizing ${AppID} ..."

        & $handler $Profile -Level $Level
    }
}

Export-ModuleMember -Function wdPersonalizeApplication

function wdEvalProfileAppsConfig {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [object] $profile,
        [Parameter(Mandatory = $false)] [switch] $PersonalizeOnly = $false,
        [Parameter(Mandatory = $false)] [int] $PersonalizeLevel = 1
    )

    process {
        $list = $profile."Rules"."Applications"
        if ($list -eq $null) {
            wdCoreLog "Profile does not have rules for: Applications"
            return
        }

        $appInstallationHandlers = @{}
        $appPersonalizationHandlers = @{}

        wdCoreLog "Loading app modules ..."

        foreach ($listprop in $list.PSObject.Properties) {
            $appId = $listprop.Name
            $rule = $listprop.Value
            if ($rule -eq $false) {
                continue
            }

            $modulePath = "${PSScriptRoot}\apps\${appId}.psm1"
            #wdCoreLog "Loading app module ${modulePath}"

            $moduleHandle = Get-Module -Name $modulePath -ListAvailable
            $module = Import-Module $moduleHandle -DisableNameChecking -AsCustomObject -PassThru

            $hook = Get-Command -Module $module | Where-Object {$_.Name -eq "hook"} | Select -First 1

            if ($hook -ne $null) {
                & $hook -InstallationHandlers $appInstallationHandlers -ConfigurationHandlers $appPersonalizationHandlers
            }
        }

        wdCoreLog "Done"

        foreach ($listprop in $list.PSObject.Properties) {
            $appId = $listprop.Name
            $rule = $listprop.Value

            if ($rule -is [string]) {
                $rule = $rule.Trim().ToLower()
            }

            if ($rule -eq $true) {
                if ($PersonalizeOnly -eq $false) {
                    wdInstallApplication $appId $profile
                }

                wdPersonalizeApplication $appId $profile -Level $PersonalizeLevel
            }
        }

    }
}

Export-ModuleMember -Function wdEvalProfileAppsConfig
