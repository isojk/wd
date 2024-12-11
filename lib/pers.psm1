[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\core.psm1




function atn_system_personalize_general ($profile) {
    $options = $profile."Rules"."System Personalization"."General"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Personalization / General"
        return
    }

    atn_core_eval_rule $options "Developer mode" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Startup sound" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 0
        }

        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableStartupSound" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" -Name "UserSetting_DisableStartupSound" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Hibernation" @{
        "enable" = {
            powercfg /hibernate on
        }

        "disable" = {
            powercfg /hibernate off
        }
    }

    # Power: Set standby delay to 24 hours
    #powercfg /change /standby-timeout-ac 1440

    atn_core_eval_rule $options "Long Paths" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Sticky Keys" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "122"
        }
    }

    atn_core_eval_rule $options "Windows Hello notifications" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" -Name "Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Windows Narrator Hotkey" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Auto-correct" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Browser tabs during alt-tab" @{
        "3 most recent tabs" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 2
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3
        }
    }

    atn_core_eval_rule $options "Game bar (ms-gamingoverlay)" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
        }
    }

    #
    # Localization
    # https://renenyffenegger.ch/notes/Windows/registry/tree/HKEY_CURRENT_USER/Control-Panel/International/index
    #

    atn_core_eval_rule $options "Time" @{
        "set_automatic" = {
            atn_core_log "Setting time automatically"
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NTP"
        }

        "set_manual" = {
            atn_core_log "Setting time manually"
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value "NoSync"
        }
    }

    atn_core_eval_rule $options "Time Zone" @{
        # 3 = Automatic, 4 = Manual

        "set_automatic" = {
            atn_core_log "Setting time zone automatically"
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 3
        }

        "set_manual" = {
            $tzvalue = $options."Time Zone Value"
            if ($tzvalue -eq $null) {
                atn_core_log_warning "Unable to set time zone manually: Missing Time Zone Value"
            }
            else {
                atn_core_log "Setting time zone manually to: ${tzvalue}"
                atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 4
                tzutil /s "${tzvalue}"
            }
        }
    }

    if (atn_core_object_hasproperty $options "First Day of Week Value") {
        $iFirstDayOfWeek = "$($options."First Day of Week Value")"
        atn_core_log "Setting first day of week to: ${iFirstDayOfWeek} (0 is monday)"
        atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "iFirstDayOfWeek" -Type String -Value $iFirstDayOfWeek
    }

    if (atn_core_object_hasproperty $options "Short Date Format Value" -and ($options."Short Date Format Value" -is [string[]])) {
        $sdfValue = $options."Short Date Format Value"
        if ($sdfValue.Length -gt 0) {
            $sShortDate = $sdfValue[0]
            atn_core_log "Setting the short date format: ${sShortDate}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sShortDate" -Type String -Value $sShortDate
        }

        if ($sdfValue.Length -gt 1) {
            $iDate = $sdfValue[1]
            atn_core_log "Setting the short date format ordering specifier to: ${iDate}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "iDate" -Type String -Value $iDate
        }

        if ($sdfValue.Length -gt 2) {
            $sDate = $sdfValue[2]
            atn_core_log "Setting the separator of day, month and year to: ${sDate}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sDate" -Type String -Value $sDate
        }
    }

    if (atn_core_object_hasproperty $options "Long Date Format Value") {
        $sLongDate = "$($options."Long Date Format Value")"
        atn_core_log "Setting the long date format to: ${sLongDate}"
        atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sLongDate" -Type String -Value $sLongDate
    }

    if (atn_core_object_hasproperty $options "Short Time Format Value") {
        $sShortTime = "$($options."Short Time Format Value")"
        atn_core_log "Setting the short time format to: ${sShortTime}"
        atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sShortTime" -Type String -Value $sShortTime
    }

    if (atn_core_object_hasproperty $options "Long Time Format Value" -and ($options."Long Time Format Value" -is [string[]])) {
        $sdfValue = $options."Long Time Format Value"
        if ($sdfValue.Length -gt 0) {
            $sTimeFormat = $sdfValue[0]
            atn_core_log "Setting the long time format to: ${sTimeFormat}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sTimeFormat" -Type String -Value $sTimeFormat
        }

        if ($sdfValue.Length -gt 1) {
            $iTime = $sdfValue[1]
            atn_core_log "Setting the long time property 'iTime' to: ${iTime}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "iTime" -Type String -Value $iTime
        }

        if ($sdfValue.Length -gt 2) {
            $iTLZero = $sdfValue[2]
            atn_core_log "Setting the long time property 'iTLZero' to: ${iTLZero}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "iTLZero" -Type String -Value $iTLZero
        }

        if ($sdfValue.Length -gt 3) {
            $iTimePrefix = $sdfValue[3]
            atn_core_log "Setting the long time property 'iTimePrefix' to: ${iTimePrefix}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "iTimePrefix" -Type String -Value $iTimePrefix
        }

        if ($sdfValue.Length -gt 4) {
            $sTime = $sdfValue[4]
            atn_core_log "Setting the long time parts separator to: ${sTime}"
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International" -Name "sTime" -Type String -Value $sTime
        }
    }
}

Export-ModuleMember -Function atn_system_personalize_general



function atn_system_personalize_explorer ($profile) {
    $options = $profile."Rules"."System Personalization"."Explorer"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Personalization / Explorer"
        return
    }

    atn_core_eval_rule $options "Compact View Mode" @{
        "show" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 1
        }

        "hide" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Hidden files" @{
        "show" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
        }

        "hide" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
        }
    }

    atn_core_eval_rule $options "File extensions" @{
        "show" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
        }

        "hide" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Path in title bar" @{
        "show" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 1
        }

        "hide" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Creating Thumbs.db files on network volumes" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 0
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Search, Task, Widget, Chat and Copilot buttons" @{
        "show" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 1
            #atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 1
        }

        "hide" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
            #atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Copilot service" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Widgets service" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "News and Interests" @{
        "enable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
        }
    }

    <#
    atn_core_eval_rule $options "Taskbar: Colors on Taskbar, Start, and SysTray" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 0
        }
    }
    #>

    <#
    atn_core_eval_rule $options "Titlebar: Theme colors on titlebar" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 0
        }
    }
    #>

    atn_core_eval_rule $options "Recycle Bin: Delete Confirmation Dialog" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Align taskbar left" @{
        # 0 = left, 1 = center
        
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Show recently added apps" @{
        "enable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 1
        }

        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 0
        }
    }

    atn_system_personalize_explorer_ctxmenu $profile
}

Export-ModuleMember -Function atn_system_personalize_explorer

function atn_system_personalize_explorer_ctxmenu ($profile) {
    $options = $profile."Rules"."System Personalization"."Explorer"."Context Menu"
    if ($options -eq $null) {
        #atn_core_log "Profile does not have rules for: System Personalization / Explorer / Context Menu"
        return
    }

    # @TODO figure out the original values of those keys
    # use at your own risk

    atn_core_eval_rule $options "Include in library" @{
        "remove" = {
            foreach ($hive in @("HKCU", "HKLM")) {
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location"
            }
        }
    }

    atn_core_eval_rule $options "Pin to Start" @{
        "remove" = {
            foreach ($hive in @("HKCU", "HKLM")) {
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\PinToStartScreen"
            }
        }
    }

    atn_core_eval_rule $options "Give access to" @{
        "remove" = {
            foreach ($hive in @("HKCU", "HKLM")) {
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\*\ShellEx\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\ShellEx\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\PropertySheetHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\PropertySheetHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing"
            }
        }
    }

    atn_core_eval_rule $options "Scan with Microsoft Defender" @{
        "remove" = {
            foreach ($hive in @("HKCU", "HKLM")) {
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\EPP"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP"
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\EPP"
            }
        }
    }

    atn_core_eval_rule $options "Send To" @{
        "remove" = {
            foreach ($hive in @("HKCU", "HKLM")) {
                atn_core_reg_remove_item -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo"
            }
        }
    }
}
