$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"

$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Console.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Env.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\..\Library\Logger.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

function Configure {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] [switch] $Yes = $false
    )

    process {
        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        if ($true -ne $Yes) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure localization now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Localization"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Localization"
            return
        }

        if ($null -ne $rules."Time") {
            $resolution = $rules."Time"."Resolution"
            switch ($resolution) {
                "automatic" {
                    & $logger.Log "Setting time automatically"
                    & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NTP"
                }

                "manual" {
                    & $logger.Log "Setting time manually"
                    & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NoSync"
                }

                _ {
                    & $logger.LogWarning "Unknown time resolution mode {0}" $resolution
                }
            }
        }

        if ($null -ne $rules."Time zone") {
            $resolution = $rules."Time zone"."Resolution"
            switch ($resolution) {
                "automatic" {
                    & $logger.Log "Setting time zone automatically"
                    & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 3
                }
                
                "manual" {
                    $value = $rules."Time zone"."Value"
                    if ($null -eq $value) {
                        & $logger.LogWarning "Unable to set time zone manually: Missing Time Zone Value"
                    }

                    & $logger.Log "Setting time zone manually to: {0}" $value
                    & $regutil.SetValue -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 4
                    tzutil /s "${value}"
                }

                _ {
                    & $logger.LogWarning "Unknown time zone resolution mode {0}" $resolution
                }
            }
        }

        if ($null -ne $rules."First day of week") {
            $value = $rules."First day of week"
            $intval = -1
            switch ($value) {
                "monday" {
                    $intval = 0
                }

                "tuesday" {
                    $intval = 1
                }

                "wednesday" {
                    $intval = 2
                }

                "thursday" {
                    $intval = 3
                }

                "friday" {
                    $intval = 4
                }

                "saturday" {
                    $intval = 5
                }

                "sunday" {
                    $intval = 6
                }

                _ {
                    & $logger.LogWarning "Unknown name of a first day of week {0}" $value
                }
            }

            if ($intval -gt -1) {
                & $logger.Log "Setting first day of week to {0}" $value
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "iFirstDayOfWeek" -Type String -Value $intval
            }
        }

        if ($null -ne $rules."Short date format") {
            while ($true) {
                $format = $rules."Short date format"."Format"
                $ordspec = $rules."Short date format"."Ordering specifier"
                $separator = $rules."Short date format"."Separator"

                if ($null -eq $format) {
                    & $logger.LogWarning "Missing short date format"
                    break;
                }

                & $logger.Log "Setting short date format to {0}" $format
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sShortDate" -Type String -Value $format

                if ($null -eq $ordspec) {
                    & $logger.LogWarning "Missing short date ordering specifier"
                    break;
                }

                & $logger.Log "Setting short date ordering specifier to {0}" $ordspec
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "iDate" -Type String -Value $ordspec

                if ($null -eq $separator) {
                    & $logger.LogWarning "Missing short date separator"
                    break;
                }

                & $logger.Log "Setting short date separator to {0}" $separator
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sDate" -Type String -Value $separator

                break;
            }
        }

        if ($null -ne $rules."Long date format") {
            while ($true) {
                $format = $rules."Long date format"."Format"

                if ($null -eq $format) {
                    & $logger.LogWarning "Missing long date format"
                    break;
                }

                & $logger.Log "Setting long date format to {0}" $format
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sLongDate" -Type String -Value $format

                break;
            }
        }

        if ($null -ne $rules."Short time format") {
            while ($true) {
                $format = $rules."Short time format"."Format"

                if ($null -eq $format) {
                    & $logger.LogWarning "Missing short time format"
                    break;
                }

                & $logger.Log "Setting short time format to {0}" $format
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sShortTime" -Type String -Value $format

                break;
            }
        }

        if ($null -ne $rules."Long time format") {
            while ($true) {
                $format = $rules."Long time format"."Format"
                $itime = $rules."Long time format"."iTime"
                $itlzero = $rules."Long time format"."iTLZero"
                $itimeprefix = $rules."Long time format"."iTimePrefix"
                $separator = $rules."Long time format"."Separator"

                if ($null -eq $format) {
                    & $logger.LogWarning "Missing long time format"
                    break;
                }

                & $logger.Log "Setting long time format to {0}" $format
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sTimeFormat" -Type String -Value $format

                if ($null -eq $itime) {
                    & $logger.LogWarning "Missing long time itime value"
                    break;
                }

                & $logger.Log "Setting long time itime value to {0}" $itime
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "iTime" -Type String -Value $itime

                if ($null -eq $itlzero) {
                    & $logger.LogWarning "Missing long time itlzero value"
                    break;
                }

                & $logger.Log "Setting long time itlzero value to {0}" $itlzero
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "iTLZero" -Type String -Value $itlzero

                if ($null -eq $itimeprefix) {
                    & $logger.LogWarning "Missing long time itimeprefix value"
                    break;
                }

                & $logger.Log "Setting long time itimeprefix value to {0}" $itimeprefix
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "iTimePrefix" -Type String -Value $itimeprefix

                if ($null -eq $separator) {
                    & $logger.LogWarning "Missing long time separator"
                    break;
                }

                & $logger.Log "Setting long time separator to {0}" $separator
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International" -Name "sTime" -Type String -Value $separator

                break;
            }
        }

    }
}

Export-ModuleMember -Function Configure
