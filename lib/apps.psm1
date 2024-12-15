$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

#$PSModuleAutoLoadingPreference = "All"

function wdInstallApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $AppId,
        [Parameter(Mandatory = $true)] [object] $Profile,
        [Parameter(Mandatory = $false)] [object] $InstallationHandlers = $null,
        [Parameter(Mandatory = $false)] [object] $ConfigurationHandlers = $null
    )

    process {
        if (($null -eq $InstallationHandlers) -or ($null -eq $ConfigurationHandlers)) {
            if ($null -eq $InstallationHandlers) {
                $InstallationHandlers = @{}
            }

            if (($null -eq $ConfigurationHandlers)) {
                $ConfigurationHandlers = @{}
            }

            $profileEval = (wdEvalProfileAppsConfig -Profile $Profile -SpecificAppId $AppId -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers)
            if (-not ($profileEval)) {
                return
            }
        }

        if (-not ($InstallationHandlers.Contains($AppId))) {
            Write-Host -NoNewLine "Installation routine for """
            Write-Host -NoNewLine -ForegroundColor Cyan "${AppId}"
            Write-Host """ does not exist"
            return
        }

        $handler = $InstallationHandlers[$AppId]
        Write-Host -NoNewLine "Installing application """
        Write-Host -NoNewLine -ForegroundColor Cyan "${AppId}"
        Write-Host """ ..."

        & $handler $Profile
    }
}

Export-ModuleMember -Function wdInstallApplication

function wdConfigureApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $AppID,
        [Parameter(Mandatory = $true)] [object] $Profile,
        [Parameter(Mandatory = $false)] [int] $Level = 1,
        [Parameter(Mandatory = $false)] [object] $InstallationHandlers = $null,
        [Parameter(Mandatory = $false)] [object] $ConfigurationHandlers = $null
    )

    process {
        if (($null -eq $InstallationHandlers) -or ($null -eq $ConfigurationHandlers)) {
            if ($null -eq $InstallationHandlers) {
                $InstallationHandlers = @{}
            }

            if (($null -eq $ConfigurationHandlers)) {
                $ConfigurationHandlers = @{}
            }

            $profileEval = (wdEvalProfileAppsConfig -Profile $Profile -SpecificAppId $AppId -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers)
            if (-not ($profileEval)) {
                return
            }
        }

        if (-not $ConfigurationHandlers.Contains($AppID)) {
            Write-Host -NoNewLine "Configuration routine for """
            Write-Host -NoNewLine -ForegroundColor Cyan "${AppId}"
            Write-Host """ does not exist"
            return
        }

        $handler = $ConfigurationHandlers[$AppID]
        Write-Host -NoNewLine "Configuring application """
        Write-Host -NoNewLine -ForegroundColor Cyan "${AppId}"
        Write-Host """ ..."

        & $handler $Profile -Level $Level
    }
}

Export-ModuleMember -Function wdConfigureApplication

function wdHandleAllProfileApps {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $Profile,
        [Parameter(Mandatory = $false)] [bool] $Install = $true,
        [Parameter(Mandatory = $false)] [bool] $Configure = $true,
        [Parameter(Mandatory = $false)] [int] $CfgLevel = 1,
        [Parameter(Mandatory = $false)] [object] $InstallationHandlers = $null,
        [Parameter(Mandatory = $false)] [object] $ConfigurationHandlers = $null
    )

    process {
        $list = $Profile."Rules"."Applications"
        if ($list -eq $null) {
            wdCoreLog "Profile does not have rules for: Applications"
            return $false
        }

        if (($null -eq $InstallationHandlers) -or ($null -eq $ConfigurationHandlers)) {
            if ($null -eq $InstallationHandlers) {
                $InstallationHandlers = @{}
            }

            if (($null -eq $ConfigurationHandlers)) {
                $ConfigurationHandlers = @{}
            }

            $profileEval = (wdEvalProfileAppsConfig -Profile $Profile -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers)
            if (-not ($profileEval)) {
                return
            }
        }

        foreach ($listprop in $list.PSObject.Properties) {
            $appId = $listprop.Name
            $rule = $listprop.Value

            if ($rule -is [string]) {
                $rule = $rule.Trim().ToLower()
            }

            if ($rule -eq $true) {
                if ($Install) {
                    wdInstallApplication -AppId $appId -Profile $Profile -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers
                }

                if ($Configure) {
                    wdConfigureApplication -AppId $appId -Profile $Profile -Level $CfgLevel -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers
                }
            }
        }

    }
}

Export-ModuleMember -Function wdHandleAllProfileApps

function wdEvalProfileAppsConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $Profile,
        [Parameter(Mandatory = $true)] [object] $InstallationHandlers,
        [Parameter(Mandatory = $true)] [object] $ConfigurationHandlers,
        [Parameter(Mandatory = $false)] [string] $SpecificAppId = $null
    )

    process {
        $list = $Profile."Rules"."Applications"
        if ($list -eq $null) {
            wdCoreLog "Profile does not have rules for: Applications"
            return $false
        }

        wdCoreLog "Loading app modules ..."

        foreach ($listprop in $list.PSObject.Properties) {
            $appId = $listprop.Name
            if (($SpecificAppId.Trim().Length -gt 0) -and ($appId -ne $SpecificAppId)) {
                continue
            }

            $rule = $listprop.Value
            if ($rule -eq $false) {
                continue
            }

            $modulePath = "${PSScriptRoot}\apps\${appId}.psm1"
            #wdCoreLog "Loading app module ${modulePath}"

            $moduleHandle = Get-Module -Name $modulePath -ListAvailable
            $module = Import-Module $moduleHandle -Force -DisableNameChecking -AsCustomObject -PassThru

            $hook = Get-Command -Module $module | Where-Object {$_.Name -eq "hook"} | Select -First 1

            if ($hook -ne $null) {
                & $hook -InstallationHandlers $InstallationHandlers -ConfigurationHandlers $ConfigurationHandlers
            }
        }

        wdCoreLog "App modules loaded"
        return $true
    }
}

Export-ModuleMember -Function wdEvalProfileAppsConfig
