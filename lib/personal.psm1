Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

$ErrorActionPreference = "Stop"

function wdSystemPersonalizeGeneral {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Personalization"."General"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Personalization / General"
            return
        }

        $data = (wdCoreGetDataDir)
        $private = (wdCoreGetPrivateDataDir)

        wdCoreEvalRule $options "Developer mode" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Startup sound" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 0
            }

            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Hibernation" @{
            "enable" = {
                powercfg /hibernate on
            }

            "disable" = {
                powercfg /hibernate off
            }
        }

        # Power: Set standby delay to 24 hours
        #powercfg /change /standby-timeout-ac 1440

        wdCoreEvalRule $options "Long Paths" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Sticky Keys" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "122"
            }
        }

        wdCoreEvalRule $options "Windows Hello notifications" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Windows Narrator Hotkey" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Auto-correct" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Browser tabs during alt-tab" @{
            "3 most recent tabs" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 2
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3
            }
        }

        wdCoreEvalRule $options "Game bar (ms-gamingoverlay)" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
            }
        }

        #
        # Enviroment variables from data
        #

        $env_map = @{
            Machine = "env.machine.json"
            User = "env.user.json"
        }

        $env_targets = @(
            "Machine",
            "User"
        )

        foreach ($target in $env_targets) {
            $filename = $env_map[$target]

            $env_user_path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($data, $filename))
            $env_user = @()
            if (Test-Path $env_user_path) {
                $env_user = (Get-Content $env_user_path | ConvertFrom-Json)
            }

            $env_user_private_path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($private, $filename))
            if (Test-Path $env_user_private_path) {
                $env_user_private = (Get-Content $env_user_private_path | ConvertFrom-Json)
                foreach ($privateItem in $env_user_private) {
                    $temp = $false
                    foreach ($publicItem in $env_user) {
                        if ($publicItem.key -eq $privateItem.key) {
                            $publicItem.value = $privateItem.value
                            $temp = $true
                            break
                        }
                    }

                    if ($temp -eq $false) {
                        $env_user += $privateItem
                    }
                }
            }

            foreach ($item in $env_user) {
                #[Environment]::SetEnvironmentVariable($item.key, $null, $target)
                [Environment]::SetEnvironmentVariable($item.key, $item.value, $target)
            }
        }

        #
        # Localization
        # https://renenyffenegger.ch/notes/Windows/registry/tree/HKEY_CURRENT_USER/Control-Panel/International/index
        #

        wdCoreEvalRule $options "Time" @{
            "set_automatic" = {
                wdCoreLog "Setting time automatically"
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NTP"
            }

            "set_manual" = {
                wdCoreLog "Setting time manually"
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NoSync"
            }
        }

        wdCoreEvalRule $options "Time Zone" @{
            # 3 = Automatic, 4 = Manual

            "set_automatic" = {
                wdCoreLog "Setting time zone automatically"
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 3
            }

            "set_manual" = {
                $tzvalue = $options."Time Zone Value"
                if ($tzvalue -eq $null) {
                    wdCoreLogWarning "Unable to set time zone manually: Missing Time Zone Value"
                }
                else {
                    wdCoreLog "Setting time zone manually to: ${tzvalue}"
                    wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 4
                    tzutil /s "${tzvalue}"
                }
            }
        }

        if ("First Day of Week Value" -in $options.PSobject.Properties.Name) {
            $iFirstDayOfWeek = "$($options."First Day of Week Value")"
            wdCoreLog "Setting first day of week to: ${iFirstDayOfWeek} (0 is monday)"
            wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "iFirstDayOfWeek" -Type String -Value $iFirstDayOfWeek
        }

        if (("Short Date Format Value" -in $options.PSobject.Properties.Name) -and ($options."Short Date Format Value" -is [string[]])) {
            $sdfValue = $options."Short Date Format Value"
            if ($sdfValue.Length -gt 0) {
                $sShortDate = $sdfValue[0]
                wdCoreLog "Setting the short date format: ${sShortDate}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sShortDate" -Type String -Value $sShortDate
            }

            if ($sdfValue.Length -gt 1) {
                $iDate = $sdfValue[1]
                wdCoreLog "Setting the short date format ordering specifier to: ${iDate}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "iDate" -Type String -Value $iDate
            }

            if ($sdfValue.Length -gt 2) {
                $sDate = $sdfValue[2]
                wdCoreLog "Setting the separator of day, month and year to: ${sDate}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sDate" -Type String -Value $sDate
            }
        }

        if ("Long Date Format Value" -in $options.PSobject.Properties.Name) {
            $sLongDate = "$($options."Long Date Format Value")"
            wdCoreLog "Setting the long date format to: ${sLongDate}"
            wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sLongDate" -Type String -Value $sLongDate
        }

        if ("Short Time Format Value" -in $options.PSobject.Properties.Name) {
            $sShortTime = "$($options."Short Time Format Value")"
            wdCoreLog "Setting the short time format to: ${sShortTime}"
            wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sShortTime" -Type String -Value $sShortTime
        }

        if (("Long Time Format Value" -in $options.PSobject.Properties.Name) -and ($options."Long Time Format Value" -is [string[]])) {
            $sdfValue = $options."Long Time Format Value"
            if ($sdfValue.Length -gt 0) {
                $sTimeFormat = $sdfValue[0]
                wdCoreLog "Setting the long time format to: ${sTimeFormat}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sTimeFormat" -Type String -Value $sTimeFormat
            }

            if ($sdfValue.Length -gt 1) {
                $iTime = $sdfValue[1]
                wdCoreLog "Setting the long time property 'iTime' to: ${iTime}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "iTime" -Type String -Value $iTime
            }

            if ($sdfValue.Length -gt 2) {
                $iTLZero = $sdfValue[2]
                wdCoreLog "Setting the long time property 'iTLZero' to: ${iTLZero}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "iTLZero" -Type String -Value $iTLZero
            }

            if ($sdfValue.Length -gt 3) {
                $iTimePrefix = $sdfValue[3]
                wdCoreLog "Setting the long time property 'iTimePrefix' to: ${iTimePrefix}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "iTimePrefix" -Type String -Value $iTimePrefix
            }

            if ($sdfValue.Length -gt 4) {
                $sTime = $sdfValue[4]
                wdCoreLog "Setting the long time parts separator to: ${sTime}"
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International" -Name "sTime" -Type String -Value $sTime
            }
        }
    }
}

Export-ModuleMember -Function wdSystemPersonalizeGeneral

function wdSystemPersonalizeExplorer {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Personalization"."Explorer"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Personalization / Explorer"
            return
        }

        wdCoreEvalRule $options "Compact View Mode" @{
            "show" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 1
            }

            "hide" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Hidden files" @{
            "show" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
            }

            "hide" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
            }
        }

        wdCoreEvalRule $options "File extensions" @{
            "show" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
            }

            "hide" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Path in title bar" @{
            "show" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 1
            }

            "hide" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Creating Thumbs.db files on network volumes" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 0
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Search, Task, Widget, Chat and Copilot buttons" @{
            "show" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 1
                #wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 1
            }

            "hide" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
                #wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Copilot service" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Widgets service" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "News and Interests" @{
            "enable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
            }
        }

        <#
        wdCoreEvalRule $options "Taskbar: Colors on Taskbar, Start, and SysTray" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 0
            }
        }
        #>

        <#
        wdCoreEvalRule $options "Titlebar: Theme colors on titlebar" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 0
            }
        }
        #>

        wdCoreEvalRule $options "Recycle Bin: Delete Confirmation Dialog" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Align taskbar left" @{
            # 0 = left, 1 = center
            
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Show recently added apps" @{
            "enable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 1
            }

            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 0
            }
        }

        wdSystemPersonalizeExplorerContextMenu $profile
    }
}

Export-ModuleMember -Function wdSystemPersonalizeExplorer

function wdSystemPersonalizeExplorerContextMenu {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Personalization"."Explorer"."Context Menu"
        if ($options -eq $null) {
            #wdCoreLog "Profile does not have rules for: System Personalization / Explorer / Context Menu"
            return
        }

        # @TODO figure out the original values of those keys
        # use at your own risk

        wdCoreEvalRule $options "Include in library" @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location"
                }
            }
        }

        wdCoreEvalRule $options "Pin to Start" @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\PinToStartScreen"
                }
            }
        }

        wdCoreEvalRule $options "Give access to" @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\*\ShellEx\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\ShellEx\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\PropertySheetHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\PropertySheetHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing"
                }
            }
        }

        wdCoreEvalRule $options "Scan with Microsoft Defender" @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\EPP"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP"
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\EPP"
                }
            }
        }

        wdCoreEvalRule $options "Send To" @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    wdCoreRegDelete -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo"
                }
            }
        }
    }
}

function wdSystemPersonalizeLinkBin {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $repo_bin = (wdCoreGetBinDir)
        $user_bin = (wdCoreGetUserBinDir)

        if (-not (Test-Path $repo_bin)) {
            return
        }

        if (-not (Test-Path $user_bin)) {
            New-Item -ItemType Directory -Force -Path $user_bin | Out-Null
        }

        Get-ChildItem $repo_bin | ForEach-Object {
            $filename = $_.Name
            $repo_file_path = [System.IO.Path]::Combine($repo_bin, $filename)
            $user_file_path = [System.IO.Path]::Combine($user_bin, $filename)

            if (Test-Path $user_file_path) {
                Remove-Item -Force -Path $user_file_path | Out-Null
            }

            wdCoreFSLink -Source $user_file_path -Target $repo_file_path
        }


    }
}

Export-ModuleMember -Function wdSystemPersonalizeLinkBin
