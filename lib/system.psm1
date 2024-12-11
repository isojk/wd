[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\core.psm1


function atn_system_configure_privacy ($profile) {
    $options = $profile."Rules"."System Configuration"."Privacy"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Configuration / Privacy"
        return
    }

    atn_core_eval_rule $options ".NET telemetry" @{
        "disable" = {
            [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "true", "User")
        }
    }

    atn_core_eval_rule $options "Apps having ability to use advertising ID for experiences across apps" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
            atn_core_reg_remove_item -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Id"
        }
    }

    atn_core_eval_rule $options "Tailored experiences with diagnostic data for current user" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Application launch tracking" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackProgs" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackDocs" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Activity History" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "SmartScreen Filter for Store Apps" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Key logging & transmission to Microsoft" @{
        "disable" = {
            # Disabled when Telemetry is set to Basic
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Websites having ability to access language list" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "SmartGlass" @{
        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "UserAuthPolicy" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "BluetoothPolicy" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Suggested content in settings app" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338394Enabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338396Enabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Tips and suggestions for welcome and what's new" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Tips and suggestions when I use windows" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Start Menu: Suggested content" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Start Menu: Recommended" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Start Menu: Search entries" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Suggesting ways current user can finish setting up his device to get the most out of Windows" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Sync provider ads" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Automatic installation of suggested apps" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Suggested app notifications (Ads for MS services" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" -Name "Enabled" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Showing suggestions for using mobile device with Windows (Phone Link suggestions" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Mobility" -Name "OptedIn" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Speech, Inking, & Typing getting to know user" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "Feedback: Windows asking for user feedback" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
            atn_core_reg_remove_item -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds"
        }
    }

    atn_core_eval_rule $options "Feedback: Sending Diagnostic and usage data" @{
        "disable" = {
            # Basic: 1, Enhanced: 2, Full: 3
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Block Outlook Preview from Outlook 365 in Windows Registry" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -Name "HideNewOutlookToggle" -Type DWord -Value 1
        }
    }

    atn_core_eval_rule $options "Bing Search widget" @{
        "disable" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "WebWidgetAllowed" -Type DWord -Value 0
            tskill searchui
        }
    }

    atn_core_eval_rule $options "Defender: Cloud-Based Protection" @{
        "disable" = {
            # Enabled Advanced: 2, Enabled Basic: 1, Disabled: 0
            Set-MpPreference -MAPSReporting 0
        }
    }

    atn_core_eval_rule $options "Defender: Automatic sample submission" @{
        "disable" = {
            # Prompt: 0, Auto Send Safe: 1, Never: 2, Auto Send All: 3
            Set-MpPreference -SubmitSamplesConsent 2
        }
    }

    atn_core_eval_rule $options "App having access to account info" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to calendar" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to call history" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to camera" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to contacts" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to app diagnostics" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to documents" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to downloads" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to emails" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to filesystem" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to location" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to messaging" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to microphone" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to music library" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to notifications" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to phone calls" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to pictures" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to radios" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to screenshots" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" -Name "Value" -Type String -Value "Deny"
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to tasks" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having ability to share and sync with non-explicitly-paired wireless devices over uPnP" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" -Name "Value" -Type String -Value "Deny"
        }
    }

    atn_core_eval_rule $options "App having access to videos" @{
        "deny" = {
            atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Name "Value" -Type String -Value "Deny"
        }
    }

}

Export-ModuleMember -Function atn_system_configure_privacy



function remove_appx_package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [string] $Name
    )

    Get-AppxPackage $Name -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppXProvisionedPackage -Online | Where DisplayName -Like $Name | Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction SilentlyContinue
}

function atn_system_configure_default_apps ($profile) {
    $options = $profile."Rules"."System Configuration"."Default Applications"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Configuration / Default Applications"
        return
    }

    # Big boys

    atn_core_eval_rule $options "Microsoft OneDrive" @{
        "remove_completely" = {
            remove_onedrive -Force
        }
    }

    # MS Store

    atn_core_eval_rule $options "Microsoft 3D Builder" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.3DBuilder"
        }
    }

    atn_core_eval_rule $options "Microsoft Alarms and Clock" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsAlarms"
        }
    }

    atn_core_eval_rule $options "Microsoft Bing Finance" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.BingFinance"
        }
    }

    atn_core_eval_rule $options "Microsoft Bing News" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.BingNews"
        }
    }

    atn_core_eval_rule $options "Microsoft Bing Search" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.BingSearch"
        }
    }

    atn_core_eval_rule $options "Microsoft Bing Sports" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.BingSports"
        }
    }

    atn_core_eval_rule $options "Microsoft Bing Weather" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.BingWeather"
        }
    }

    atn_core_eval_rule $options "Microsoft Calendar and Mail" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsCommunicationsApps"
        }
    }

    atn_core_eval_rule $options "Microsoft Cortana" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.549981C3F5F10"
        }
    }

    atn_core_eval_rule $options "Microsoft Feedback Hub" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsFeedbackHub"
        }
    }

    atn_core_eval_rule $options "Microsoft Get Office" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.MicrosoftOfficeHub"
        }
    }

    atn_core_eval_rule $options "Microsoft Maps" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsMaps"
        }
    }

    atn_core_eval_rule $options "Microsoft Messaging" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Messaging"
        }
    }

    atn_core_eval_rule $options "Microsoft Mobile Plans" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.OneConnect"
        }
    }

    atn_core_eval_rule $options "Microsoft OneNote" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Office.OneNote"
        }
    }

    atn_core_eval_rule $options "Microsoft Outlook" @{
        "remove" = {
            remove_appx_package -Name "*OutlookForWindows*"
        }
    }

    atn_core_eval_rule $options "Microsoft Paint" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Paint"
        }
    }

    atn_core_eval_rule $options "Microsoft People" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.People"
        }
    }

    atn_core_eval_rule $options "Microsoft Photos" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Windows.Photos"
        }
    }

    atn_core_eval_rule $options "Microsoft Print 3D" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Print3D"
        }
    }

    atn_core_eval_rule $options "Microsoft Quick Assist" @{
        "remove" = {
            remove_appx_package -Name "MicrosoftCorporationII.QuickAssist"
        }
    }

    atn_core_eval_rule $options "Microsoft Skype" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.SkypeApp"
        }
    }

    atn_core_eval_rule $options "Microsoft Solitaire" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.MicrosoftSolitaireCollection"
        }
    }

    atn_core_eval_rule $options "Microsoft Sticky Notes" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.MicrosoftStickyNotes"
        }
    }

    atn_core_eval_rule $options "Microsoft Sway" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Office.Sway"
        }
    }

    atn_core_eval_rule $options "Microsoft Todos" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.ToDos"
        }
    }

    atn_core_eval_rule $options "Microsoft Voice Recorder" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsSoundRecorder"
        }
    }

    atn_core_eval_rule $options "Microsoft Xbox" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.Xbox.TCUI"
            remove_appx_package -Name "Microsoft.XboxApp"
            remove_appx_package -Name "Microsoft.XboxGameOverlay"
            remove_appx_package -Name "Microsoft.XboxGamingOverlay"
            remove_appx_package -Name "Microsoft.XboxIdentityProvider"
            remove_appx_package -Name "Microsoft.XboxSpeechToTextOverlay"
        }
    }

    atn_core_eval_rule $options "Microsoft Your Phone" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.YourPhone"
        }
    }

    atn_core_eval_rule $options "Microsoft Windows Media Player" @{
        "remove" = {
            Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
        }
    }

    atn_core_eval_rule $options "Microsoft Windows Terminal" @{
        "remove" = {
            remove_appx_package -Name "Microsoft.WindowsTerminal"
        }
    }

    atn_core_eval_rule $options "Adobe Creative Cloud Express" @{
        "remove" = {
            remove_appx_package -Name "*AdobeCreativeCloudExpress*"
        }
    }

    atn_core_eval_rule $options "Amazon Prime Video" @{
        "remove" = {
            remove_appx_package -Name "AmazonVideo.PrimeVideo"
        }
    }

    atn_core_eval_rule $options "Autodesk Sketch book" @{
        "remove" = {
            remove_appx_package -Name "*AutodeskSketchBook*"
        }
    }

    atn_core_eval_rule $options "Bubble Witch 3 Saga" @{
        "remove" = {
            remove_appx_package -Name "*BubbleWitch3Saga*"
        }
    }

    atn_core_eval_rule $options "Candy Crush Soda Saga" @{
        "remove" = {
            remove_appx_package -Name "*CandyCrushSodaSaga*"
        }
    }

    atn_core_eval_rule $options "Clipchamp Video Editor" @{
        "remove" = {
            remove_appx_package -Name "Clipchamp.Clipchamp"
        }
    }

    atn_core_eval_rule $options "Disney Magic Kingdoms" @{
        "remove" = {
            remove_appx_package -Name "*DisneyMagicKingdoms*"
        }
    }

    atn_core_eval_rule $options "Disney+" @{
        "remove" = {
            remove_appx_package -Name "Disney.37853FC22B2CE"
        }
    }

    atn_core_eval_rule $options "Dolby" @{
        "remove" = {
            remove_appx_package -Name "DolbyLaboratories.DolbyAccess"
        }
    }

    atn_core_eval_rule $options "Facebook" @{
        "remove" = {
            remove_appx_package -Name "*Facebook*"
        }
    }

    atn_core_eval_rule $options "Instagram" @{
        "remove" = {
            remove_appx_package -Name "*Instagram*"
        }
    }

    atn_core_eval_rule $options "March of Empires" @{
        "remove" = {
            remove_appx_package -Name "*MarchofEmpires*"
        }
    }

    atn_core_eval_rule $options "SlingTV" @{
        "remove" = {
            remove_appx_package -Name "*SlingTV*"
        }
    }

    atn_core_eval_rule $options "Spotify" @{
        "remove" = {
            remove_appx_package -Name "*spotify*"
        }
    }

    atn_core_eval_rule $options "TikTok" @{
        "remove" = {
            remove_appx_package -Name "*tiktok*"
        }
    }

    atn_core_eval_rule $options "Twitter" @{
        "remove" = {
            remove_appx_package -Name "*twitter*"
        }
    }

    atn_core_eval_rule $options "Zune Music" @{
        "remove" = {
            remove_appx_package -Name "*zunemusic*"
        }
    }

    atn_core_eval_rule $options "Zune Video" @{
        "remove" = {
            remove_appx_package -Name "*zunevideo*"
        }
    }
}

Export-ModuleMember -Function atn_system_configure_default_apps


function remove_onedrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [switch] $Force = $false
    )

    # Stop OneDrive
    atn_core_log "Stopping OneDrive"
    taskkill.exe /F /IM "OneDrive.exe"
    #taskkill.exe /F /IM "explorer.exe"

    # Uninstall OneDrive
    atn_core_log "Uninstalling OneDrive"
    if (Test-Path "$Env:SystemRoot\System32\OneDriveSetup.exe") {
        & "$Env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
    }
    if (Test-Path "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
        & "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall
    }

    # Disable OneDrive via Group Policies
    atn_core_log "Disabling OneDrive via Group Policies"
    atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

    # Remove OneDrive leftovers trash
    atn_core_log "Removing OneDrive leftovers trash"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:LOCALAPPDATA\Microsoft\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:ProgramData\Microsoft OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:SystemDrive\OneDriveTemp"

    # Remove Onedrive from explorer sidebar
    atn_core_log "Removing Onedrive from explorer sidebar"
    if (!(Test-Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")) {
        New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Type Folder | Out-Null
    }

    Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0

    if (!(Test-Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")) {
        New-Item -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Type Folder | Out-Null
    }

    Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0

    # Remove run option for new users
    atn_core_log "Removing run option for new users"
    reg load "hku\Default" "$Env:SystemDrive\Users\Default\NTUSER.DAT"
    reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
    reg unload "hku\Default"

    # Remove startmenu junk entry
    atn_core_log "Removing startmenu junk entry"
    Remove-Item -Force -ErrorAction SilentlyContinue "$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

    #atn_core_log "Starting explorer"
    #start "explorer.exe"
    #sleep 4

    # Remove additional OneDrive leftovers
    #atn_core_log "Removing additional OneDrive leftovers"
    #foreach ($item in (ls "$Env:windir\WinSxS\*onedrive*")) {
        #atn_core_takeown_folder $item.FullName
        #Remove-Item -Recurse -Force $item.FullName
    #}

    if (!(Test-Path "$Env:USERPROFILE\Desktop")) {
        atn_core_log "Creating new directory: $Env:USERPROFILE\Desktop"
        New-Item -Path "$Env:USERPROFILE\Desktop" -Type "directory" | Out-Null
    }

    if (!(Test-Path "$Env:USERPROFILE\Documents")) {
        atn_core_log "Creating new directory: $Env:USERPROFILE\Documents"
        New-Item -Path "$Env:USERPROFILE\Documents" -Type "directory" | Out-Null
    }

    if (!(Test-Path "$Env:USERPROFILE\Pictures")) {
        atn_core_log "Creating new directory: $Env:USERPROFILE\Pictures"
        New-Item -Path "$Env:USERPROFILE\Pictures" -Type "directory" | Out-Null
    }

    atn_core_log "Relinking user shell folders to canonical ones in user profile"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Type String -Value "%USERPROFILE%\Pictures"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Type String -Value "%USERPROFILE%\Downloads"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Type String -Value "%USERPROFILE%\Documents"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Type String -Value "%USERPROFILE%\Desktop"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Type String -Value "%USERPROFILE%\Pictures"
    atn_core_reg_set -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Type String -Value "%USERPROFILE%\Documents"

    if (Test-Path "$Env:USERPROFILE\OneDrive") {
        if (Test-Path "$Env:USERPROFILE\OneDrive\Desktop") {
            atn_core_log "Moving directory: $Env:USERPROFILE\OneDrive\Desktop"
            Move-Item -Force "$Env:USERPROFILE\OneDrive\Desktop\*" "$Env:USERPROFILE\Desktop"
        }

        if (Test-Path "$Env:USERPROFILE\OneDrive\Documents") {
            atn_core_log "Moving directory: $Env:USERPROFILE\OneDrive\Documents"
            Move-Item -Force "$Env:USERPROFILE\OneDrive\Documents\*" "$Env:USERPROFILE\Documents"
        }

        if (Test-Path "$Env:USERPROFILE\OneDrive\Pictures") {
            atn_core_log "Moving directory: $Env:USERPROFILE\OneDrive\Pictures"
            Move-Item -Force "$Env:USERPROFILE\OneDrive\Pictures\*" "$Env:USERPROFILE\Pictures"
        }

        atn_core_log "Removing directory: $Env:USERPROFILE\OneDrive"
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\OneDrive"
    }

    atn_core_log "Remove OneDrive environment variables"
    [Environment]::SetEnvironmentVariable("OneDrive", $null, "User")
    [Environment]::SetEnvironmentVariable("OneDriveConsumer", $null, "User")
}



function atn_system_configure_general ($profile) {
    $options = $profile."Rules"."System Configuration"."General"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Configuration / General"
        return
    }

    atn_core_eval_rule $options "Edge running in background" @{
        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "HubsSidebarEnabled" -Type DWord -Value 0
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0

            $microsoftEdgeAutoLaunchPropertyName = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | get-member | ? {$_.memberType -eq 'NoteProperty'} | ? {$_.name -notmatch '^PS'} | Where-Object {$_.Name -Like "MicrosoftEdge*"} | Select-Object -Expand Name)
            if ($microsoftEdgeAutoLaunchPropertyName) {
                Remove-ItemProperty -Force -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $microsoftEdgeAutoLaunchPropertyName -ErrorAction SilentlyContinue
            }
        }
    }

    atn_core_eval_rule $options "Superfetch" @{
        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 0
        }
    }

    atn_core_eval_rule $options "WiFi Sense" @{
        "disable" = {
            atn_core_reg_set -Hive "HKLM" -Path "SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
        }
    }

    #
    # WSL
    #

    if ($options."WSL" -ne $null) {
        $enabled = $false
        switch ($options."WSL"."action") {
            "enable" {
                Enable-WindowsOptionalFeature -Online -All -FeatureName "VirtualMachinePlatform" -NoRestart
                Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
                $enabled = $true
            }

            "disable" {
                wsl --shutdown

                Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
                Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart
            }
        }

        if ($enabled) {
            $distributions = $options."WSL"."distributions"
            if ($distributions -is [object[]]) {
                foreach ($dist in $distributions) {
                    $name = $dist."name"
                    if ($name -is [string] -and ($name.Length -gt 0)) {
                        wsl --update
                        # @TODO
                        #wsl --install -d $distribution
                    }
                }
            }
        }
    }
}

Export-ModuleMember -Function atn_system_configure_general



function atn_system_remove_junk ($profile) {
    $options = $profile."Rules"."System Configuration"."Junk"
    if ($options -eq $null) {
        atn_core_log "Profile does not have rules for: System Configuration / Junk"
        return
    }

    atn_core_eval_rule $options "Contacts (user profile)" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\Contacts") {
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Contacts"
            }
        }
    }

    atn_core_eval_rule $options "Favorites (user profile)" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\Favorites") {
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Favorites"
            }
        }
    }

    atn_core_eval_rule $options "Links (user profile)" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\Links") {
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Links"
            }
        }
    }

    atn_core_eval_rule $options "SavedGames (user profile)" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\Saved Games") {
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Saved Games"
            }
        }
    }

    atn_core_eval_rule $options "Searches (user profile)" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\Searches") {
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Searches"
            }
        }
    }

    atn_core_eval_rule $options ".lesshst" @{
        "remove" = {
            if (Test-Path "$Env:USERPROFILE\.lesshst") {
                Remove-Item -Force -ErrorAction SilentlyContinue "$Env:USERPROFILE\.lesshst"
            }
        }
    }
}

Export-ModuleMember -Function atn_system_remove_junk
