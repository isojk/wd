$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"

$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Console.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Env.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\..\Library\Logger.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

$privacyModule = ImportModuleAsObject "$PSScriptRoot\System.Privacy.psm1"
$defaultAppsModule = ImportModuleAsObject "$PSScriptRoot\System.DefaultApps.psm1"
$localizationModule = ImportModuleAsObject "$PSScriptRoot\System.Localization.psm1"
$explorerModule = ImportModuleAsObject "$PSScriptRoot\System.Explorer.psm1"

function ConfigurePrivacyOptions {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sa = @{
            "Yes" = $null
        }

        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $sa["Yes"] = $arg.Value }
            }
        }

        & $privacyModule.Configure -Profile $Profile @sa
    }
}

function ConfigureDefaultApps {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sa = @{
            "Yes" = $null
        }

        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $sa["Yes"] = $arg.Value }
            }
        }

        & $defaultAppsModule.Configure -Profile $Profile @sa
    }
}

function ConfigureLocalization {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sa = @{
            "Yes" = $null
        }

        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $sa["Yes"] = $arg.Value }
            }
        }

        & $localizationModule.Configure -Profile $Profile @sa
    }
}

function ConfigureExplorer {    
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sa = @{
            "Yes" = $null
        }

        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $sa["Yes"] = $arg.Value }
            }
        }

        & $explorerModule.Configure -Profile $Profile @sa
    }
}

function ConfigureAutoruns {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $Yes = $false
        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $Yes = $arg.Value }
            }
        }

        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        if ($true -ne $Yes) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure autoruns now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Autoruns"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Autoruns"
            return
        }

        $rules.EvalRule("Edge", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "HubsSidebarEnabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0

                # @TODO
                $microsoftEdgeAutoLaunchPropertyName = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | get-member | ? {$_.memberType -eq 'NoteProperty'} | ? {$_.name -notmatch '^PS'} | Where-Object {$_.Name -Like "MicrosoftEdge*"} | Select-Object -Expand Name)
                if ($microsoftEdgeAutoLaunchPropertyName) {
                    Remove-ItemProperty -Force -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $microsoftEdgeAutoLaunchPropertyName -ErrorAction SilentlyContinue
                }
            }
        })
    }
}

function ConfigureEnvironmentVariables {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $Yes = $false
        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $Yes = $arg.Value }
            }
        }

        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        if ($true -ne $Yes) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure environment variables now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Environment variables"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Environment variables"
            return
        }

        $env_targets = @(
            "Machine",
            "User"
        )

        foreach ($target in $env_targets) {
            $data = [PSCustomObject] @{}
            if ($null -ne $rules."${target}") {
                $data = $rules."${target}"
            }

            foreach ($prop in $data.PSObject.Properties) {
                & $logger.Log "{0} = {1}" $prop.Name $prop.Value

                #[Environment]::SetEnvironmentVariable($prop.Name, $null, $target)
                [Environment]::SetEnvironmentVariable($prop.Name, $prop.Value, $target)
            }
        }
    }
}

function ConfigureOtherFeatures {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $Yes = $false
        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Yes" { $Yes = $arg.Value }
            }
        }

        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        if ($true -ne $Yes) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure other system features now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Other features"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Other features"
            return
        }

        $rules.EvalRule("Auto-correct", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Browser tabs during alt-tab", @{
            "recent3" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 2
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3
            }
        })

        $rules.EvalRule("Developer mode", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Game bar (ms-gamingoverlay)", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Hibernation", @{
            "enable" = {
                powercfg /hibernate on
            }

            "disable" = {
                powercfg /hibernate off
            }
        })

        $rules.EvalRule("Long paths", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Startup sound", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 0
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Sticky keys", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "122"
            }
        })

        $rules.EvalRule("Sudo", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo" -Name "Enabled" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo" -Name "Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Superfetch", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Windows Hello notifications", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Windows Narrator hotkey", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 0
            }
        })

        #
        # WSL
        #

        <#
            #!/usr/bin/env bash
            echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER"
            @TODO
        #>

        if ($null -ne $rules."WSL") {
            while ($true) {
                $enabled = $false
                switch ($rules."WSL"."Action") {
                    "enable" {
                        & $logger.Log "Enabling optional feature: VirtualMachinePlatform"
                        Enable-WindowsOptionalFeature -Online -All -FeatureName "VirtualMachinePlatform" -NoRestart | Out-Null

                        & $logger.Log "Enabling optional feature: Microsoft-Windows-Subsystem-Linux"
                        Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart | Out-Null

                        $enabled = $true
                    }

                    "disable" {
                        & $logger.Log "Shutting down WSL"
                        wsl --shutdown | Out-Null

                        & $logger.Log "Disabling optional feature: VirtualMachinePlatform"
                        Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart | Out-Null

                        & $logger.Log "Disabling optional feature: Microsoft-Windows-Subsystem-Linux"
                        Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart | Out-Null
                    }
                }

                if ($enable -eq $false) {
                    break;
                }

                $distributions = $rules."WSL"."Distributions"
                if ($distributions -is [PSCustomObject[]]) {
                    foreach ($dist in $distributions) {
                        $name = $dist."Name"
                        if ($name -is [string] -and ($name.Length -gt 0)) {
                            # @TODO
                            #wsl --update
                            #wsl --install -d $distribution
                        }
                    }
                }

                break;
            }
        }
    }
}

$Commands = @{
    "PrivacyOptions" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigurePrivacyOptions -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "DefaultApps" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureDefaultApps -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "Autoruns" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureAutoruns -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "EnvVars" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureEnvironmentVariables -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "Localization" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureLocalization -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "Explorer" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureExplorer -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "Other" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigureOtherFeatures -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "All" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ConfigurePrivacyOptions -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureDefaultApps -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureAutoruns -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureEnvironmentVariables -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureLocalization -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureExplorer -Profile $Profile -CommandArgs $CommandArgs
            & ConfigureOtherFeatures -Profile $Profile -CommandArgs $CommandArgs
        }
    }
}

function PrintHelp {
    [CmdletBinding(PositionalBinding = $false)]
    param()

    process {
        $subnames = New-Object "System.Collections.Generic.List[string]"
        foreach ($cmdkvp in $Commands.GetEnumerator()) {
            $cmdname = $cmdkvp.Key
            $cmdobj = $cmdkvp.Value

            $subnames.Add($cmdname) | Out-Null
        }

        $allSubnames = ([string]::Join("|", $subnames))

        Write-Host "Usage: wd System <${allSubnames}>"
    }
}

function Configure {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] [switch] $Help = $false,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sub = $null
        foreach ($ca in $CommandArgs) {
            if ($ca.Key -eq $null -and $ca.Value -ne $null) {
                $sub = $ca.Value
                break
            }
        }

        if (-not ($sub)) {
            if ($Help -eq $true) {
                & PrintHelp
                return
            }

            Write-Error "Missing group"
            return
        }

        if (-not ($Commands.ContainsKey($sub))) {
            Write-Error "Unknown group ""${sub}"""
            return
        }

        $cmdobj = $Commands["${sub}"]
        & $cmdobj.Action -Profile $Profile -CommandArgs $CommandArgs
    }
}

Export-ModuleMember -Function Configure
