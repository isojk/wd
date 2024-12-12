Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking

function wdSystemConfigurePrivacy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Configuration"."Privacy"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Configuration / Privacy"
            return
        }

        wdCoreEvalRule $options ".NET telemetry" @{
            "disable" = {
                [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "true", "User")
            }
        }

        wdCoreEvalRule $options "Apps having ability to use advertising ID for experiences across apps" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
                wdCoreRegDelete -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Id"
            }
        }

        wdCoreEvalRule $options "Tailored experiences with diagnostic data for current user" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Application launch tracking" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackProgs" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackDocs" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Activity History" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "SmartScreen Filter for Store Apps" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Key logging & transmission to Microsoft" @{
            "disable" = {
                # Disabled when Telemetry is set to Basic
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Websites having ability to access language list" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "SmartGlass" @{
            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "UserAuthPolicy" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "BluetoothPolicy" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Suggested content in settings app" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338394Enabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338396Enabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Tips and suggestions for welcome and what's new" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Tips and suggestions when I use windows" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Start Menu: Suggested content" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Start Menu: Recommended" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Start Menu: Search entries" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Suggesting ways current user can finish setting up his device to get the most out of Windows" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Sync provider ads" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Automatic installation of suggested apps" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Suggested app notifications (Ads for MS services)" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" -Name "Enabled" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Showing suggestions for using mobile device with Windows (Phone Link suggestions)" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Mobility" -Name "OptedIn" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Speech, Inking, & Typing getting to know user" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "Feedback: Windows asking for user feedback" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
                wdCoreRegDelete -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds"
            }
        }

        wdCoreEvalRule $options "Feedback: Sending Diagnostic and usage data" @{
            "disable" = {
                # Basic: 1, Enhanced: 2, Full: 3
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Block Outlook Preview from Outlook 365 in Windows Registry" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -Name "HideNewOutlookToggle" -Type DWord -Value 1
            }
        }

        wdCoreEvalRule $options "Bing Search widget" @{
            "disable" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "WebWidgetAllowed" -Type DWord -Value 0
                tskill searchui
            }
        }

        wdCoreEvalRule $options "Defender: Cloud-Based Protection" @{
            "disable" = {
                # Enabled Advanced: 2, Enabled Basic: 1, Disabled: 0
                Set-MpPreference -MAPSReporting 0
            }
        }

        wdCoreEvalRule $options "Defender: Automatic sample submission" @{
            "disable" = {
                # Prompt: 0, Auto Send Safe: 1, Never: 2, Auto Send All: 3
                Set-MpPreference -SubmitSamplesConsent 2
            }
        }

        wdCoreEvalRule $options "App having access to account info" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to calendar" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to call history" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to camera" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to contacts" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to app diagnostics" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to documents" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to downloads" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to emails" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to filesystem" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to location" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to messaging" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to microphone" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to music library" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to notifications" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to phone calls" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to pictures" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to radios" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to screenshots" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" -Name "Value" -Type String -Value "Deny"
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to tasks" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having ability to share and sync with non-explicitly-paired wireless devices over uPnP" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" -Name "Value" -Type String -Value "Deny"
            }
        }

        wdCoreEvalRule $options "App having access to videos" @{
            "deny" = {
                wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Name "Value" -Type String -Value "Deny"
            }
        }
    }
}

Export-ModuleMember -Function wdSystemConfigurePrivacy

#
#
#

function removeAppxPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Name
    )

    process {
        Get-AppxPackage $Name -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppXProvisionedPackage -Online | Where DisplayName -Like $Name | Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction SilentlyContinue
    }
}

function wdSystemConfigureDefaultApps {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Configuration"."Default Applications"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Configuration / Default Applications"
            return
        }

        # Big boys

        wdCoreEvalRule $options "Microsoft OneDrive" @{
            "remove_completely" = {
                removeOnedrive -Force
            }
        }

        # MS Store

        wdCoreEvalRule $options "Microsoft 3D Builder" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.3DBuilder"
            }
        }

        wdCoreEvalRule $options "Microsoft Alarms and Clock" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsAlarms"
            }
        }

        wdCoreEvalRule $options "Microsoft Bing Finance" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.BingFinance"
            }
        }

        wdCoreEvalRule $options "Microsoft Bing News" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.BingNews"
            }
        }

        wdCoreEvalRule $options "Microsoft Bing Search" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.BingSearch"
            }
        }

        wdCoreEvalRule $options "Microsoft Bing Sports" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.BingSports"
            }
        }

        wdCoreEvalRule $options "Microsoft Bing Weather" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.BingWeather"
            }
        }

        wdCoreEvalRule $options "Microsoft Calendar and Mail" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsCommunicationsApps"
            }
        }

        wdCoreEvalRule $options "Microsoft Cortana" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.549981C3F5F10"
            }
        }

        wdCoreEvalRule $options "Microsoft Feedback Hub" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsFeedbackHub"
            }
        }

        wdCoreEvalRule $options "Microsoft Get Office" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.MicrosoftOfficeHub"
            }
        }

        wdCoreEvalRule $options "Microsoft Maps" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsMaps"
            }
        }

        wdCoreEvalRule $options "Microsoft Messaging" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Messaging"
            }
        }

        wdCoreEvalRule $options "Microsoft Mobile Plans" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.OneConnect"
            }
        }

        wdCoreEvalRule $options "Microsoft OneNote" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Office.OneNote"
            }
        }

        wdCoreEvalRule $options "Microsoft Outlook" @{
            "remove" = {
                removeAppxPackage -Name "*OutlookForWindows*"
            }
        }

        wdCoreEvalRule $options "Microsoft Paint" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Paint"
            }
        }

        wdCoreEvalRule $options "Microsoft People" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.People"
            }
        }

        wdCoreEvalRule $options "Microsoft Photos" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Windows.Photos"
            }
        }

        wdCoreEvalRule $options "Microsoft Print 3D" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Print3D"
            }
        }

        wdCoreEvalRule $options "Microsoft Quick Assist" @{
            "remove" = {
                removeAppxPackage -Name "MicrosoftCorporationII.QuickAssist"
            }
        }

        wdCoreEvalRule $options "Microsoft Skype" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.SkypeApp"
            }
        }

        wdCoreEvalRule $options "Microsoft Solitaire" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.MicrosoftSolitaireCollection"
            }
        }

        wdCoreEvalRule $options "Microsoft Sticky Notes" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.MicrosoftStickyNotes"
            }
        }

        wdCoreEvalRule $options "Microsoft Sway" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Office.Sway"
            }
        }

        wdCoreEvalRule $options "Microsoft Todos" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.ToDos"
            }
        }

        wdCoreEvalRule $options "Microsoft Voice Recorder" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsSoundRecorder"
            }
        }

        wdCoreEvalRule $options "Microsoft Xbox" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.Xbox.TCUI"
                removeAppxPackage -Name "Microsoft.XboxApp"
                removeAppxPackage -Name "Microsoft.XboxGameOverlay"
                removeAppxPackage -Name "Microsoft.XboxGamingOverlay"
                removeAppxPackage -Name "Microsoft.XboxIdentityProvider"
                removeAppxPackage -Name "Microsoft.XboxSpeechToTextOverlay"
            }
        }

        wdCoreEvalRule $options "Microsoft Your Phone" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.YourPhone"
            }
        }

        wdCoreEvalRule $options "Microsoft Windows Media Player" @{
            "remove" = {
                Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
            }
        }

        wdCoreEvalRule $options "Microsoft Windows Terminal" @{
            "remove" = {
                removeAppxPackage -Name "Microsoft.WindowsTerminal"
            }
        }

        wdCoreEvalRule $options "Adobe Creative Cloud Express" @{
            "remove" = {
                removeAppxPackage -Name "*AdobeCreativeCloudExpress*"
            }
        }

        wdCoreEvalRule $options "Amazon Prime Video" @{
            "remove" = {
                removeAppxPackage -Name "AmazonVideo.PrimeVideo"
            }
        }

        wdCoreEvalRule $options "Autodesk Sketch book" @{
            "remove" = {
                removeAppxPackage -Name "*AutodeskSketchBook*"
            }
        }

        wdCoreEvalRule $options "Bubble Witch 3 Saga" @{
            "remove" = {
                removeAppxPackage -Name "*BubbleWitch3Saga*"
            }
        }

        wdCoreEvalRule $options "Candy Crush Soda Saga" @{
            "remove" = {
                removeAppxPackage -Name "*CandyCrushSodaSaga*"
            }
        }

        wdCoreEvalRule $options "Clipchamp Video Editor" @{
            "remove" = {
                removeAppxPackage -Name "Clipchamp.Clipchamp"
            }
        }

        wdCoreEvalRule $options "Disney Magic Kingdoms" @{
            "remove" = {
                removeAppxPackage -Name "*DisneyMagicKingdoms*"
            }
        }

        wdCoreEvalRule $options "Disney+" @{
            "remove" = {
                removeAppxPackage -Name "Disney.37853FC22B2CE"
            }
        }

        wdCoreEvalRule $options "Dolby" @{
            "remove" = {
                removeAppxPackage -Name "DolbyLaboratories.DolbyAccess"
            }
        }

        wdCoreEvalRule $options "Facebook" @{
            "remove" = {
                removeAppxPackage -Name "*Facebook*"
            }
        }

        wdCoreEvalRule $options "Instagram" @{
            "remove" = {
                removeAppxPackage -Name "*Instagram*"
            }
        }

        wdCoreEvalRule $options "March of Empires" @{
            "remove" = {
                removeAppxPackage -Name "*MarchofEmpires*"
            }
        }

        wdCoreEvalRule $options "SlingTV" @{
            "remove" = {
                removeAppxPackage -Name "*SlingTV*"
            }
        }

        wdCoreEvalRule $options "Spotify" @{
            "remove" = {
                removeAppxPackage -Name "*spotify*"
            }
        }

        wdCoreEvalRule $options "TikTok" @{
            "remove" = {
                removeAppxPackage -Name "*tiktok*"
            }
        }

        wdCoreEvalRule $options "Twitter" @{
            "remove" = {
                removeAppxPackage -Name "*twitter*"
            }
        }

        wdCoreEvalRule $options "Zune Music" @{
            "remove" = {
                removeAppxPackage -Name "*zunemusic*"
            }
        }

        wdCoreEvalRule $options "Zune Video" @{
            "remove" = {
                removeAppxPackage -Name "*zunevideo*"
            }
        }
    }
}

Export-ModuleMember -Function wdSystemConfigureDefaultApps

function removeOnedrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [switch] $Force = $false
    )

    process {
        # Stop OneDrive
        wdCoreLog "Stopping OneDrive"
        taskkill.exe /F /IM "OneDrive.exe"
        #taskkill.exe /F /IM "explorer.exe"

        # Uninstall OneDrive
        wdCoreLog "Uninstalling OneDrive"
        if (Test-Path "$Env:SystemRoot\System32\OneDriveSetup.exe") {
            & "$Env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
        }
        if (Test-Path "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
            & "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall
        }

        # Disable OneDrive via Group Policies
        wdCoreLog "Disabling OneDrive via Group Policies"
        wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

        # Remove OneDrive leftovers trash
        wdCoreLog "Removing OneDrive leftovers trash"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:LOCALAPPDATA\Microsoft\OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:ProgramData\Microsoft OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:SystemDrive\OneDriveTemp"

        # Remove Onedrive from explorer sidebar
        wdCoreLog "Removing Onedrive from explorer sidebar"
        if (!(Test-Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")) {
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Type Folder | Out-Null
        }

        Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0

        if (!(Test-Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")) {
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Type Folder | Out-Null
        }

        Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0

        # Remove run option for new users
        wdCoreLog "Removing run option for new users"
        reg load "hku\Default" "$Env:SystemDrive\Users\Default\NTUSER.DAT"
        reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
        reg unload "hku\Default"

        # Remove startmenu junk entry
        wdCoreLog "Removing startmenu junk entry"
        Remove-Item -Force -ErrorAction SilentlyContinue "$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

        #wdCoreLog "Starting explorer"
        #start "explorer.exe"
        #sleep 4

        # Remove additional OneDrive leftovers
        #wdCoreLog "Removing additional OneDrive leftovers"
        #foreach ($item in (ls "$Env:windir\WinSxS\*onedrive*")) {
            #atn_core_takeown_folder $item.FullName
            #Remove-Item -Recurse -Force $item.FullName
        #}

        if (!(Test-Path "$Env:USERPROFILE\Desktop")) {
            wdCoreLog "Creating new directory: $Env:USERPROFILE\Desktop"
            New-Item -Path "$Env:USERPROFILE\Desktop" -Type "directory" | Out-Null
        }

        if (!(Test-Path "$Env:USERPROFILE\Documents")) {
            wdCoreLog "Creating new directory: $Env:USERPROFILE\Documents"
            New-Item -Path "$Env:USERPROFILE\Documents" -Type "directory" | Out-Null
        }

        if (!(Test-Path "$Env:USERPROFILE\Pictures")) {
            wdCoreLog "Creating new directory: $Env:USERPROFILE\Pictures"
            New-Item -Path "$Env:USERPROFILE\Pictures" -Type "directory" | Out-Null
        }

        wdCoreLog "Relinking user shell folders to canonical ones in user profile"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Type String -Value "%USERPROFILE%\Pictures"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Type String -Value "%USERPROFILE%\Downloads"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Type String -Value "%USERPROFILE%\Documents"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Type String -Value "%USERPROFILE%\Desktop"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Type String -Value "%USERPROFILE%\Pictures"
        wdCoreRegSet -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Type String -Value "%USERPROFILE%\Documents"

        if (Test-Path "$Env:USERPROFILE\OneDrive") {
            if (Test-Path "$Env:USERPROFILE\OneDrive\Desktop") {
                wdCoreLog "Moving directory: $Env:USERPROFILE\OneDrive\Desktop"
                Move-Item -Force "$Env:USERPROFILE\OneDrive\Desktop\*" "$Env:USERPROFILE\Desktop"
            }

            if (Test-Path "$Env:USERPROFILE\OneDrive\Documents") {
                wdCoreLog "Moving directory: $Env:USERPROFILE\OneDrive\Documents"
                Move-Item -Force "$Env:USERPROFILE\OneDrive\Documents\*" "$Env:USERPROFILE\Documents"
            }

            if (Test-Path "$Env:USERPROFILE\OneDrive\Pictures") {
                wdCoreLog "Moving directory: $Env:USERPROFILE\OneDrive\Pictures"
                Move-Item -Force "$Env:USERPROFILE\OneDrive\Pictures\*" "$Env:USERPROFILE\Pictures"
            }

            wdCoreLog "Removing directory: $Env:USERPROFILE\OneDrive"
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\OneDrive"
        }

        wdCoreLog "Remove OneDrive environment variables"
        [Environment]::SetEnvironmentVariable("OneDrive", $null, "User")
        [Environment]::SetEnvironmentVariable("OneDriveConsumer", $null, "User")
    }
}

function wdSystemConfigureGeneral {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Configuration"."General"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Configuration / General"
            return
        }

        wdCoreEvalRule $options "Edge running in background" @{
            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "HubsSidebarEnabled" -Type DWord -Value 0
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge\Recommended" -Name "StandaloneHubsSidebarEnabled" -Type DWord -Value 0

                $microsoftEdgeAutoLaunchPropertyName = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | get-member | ? {$_.memberType -eq 'NoteProperty'} | ? {$_.name -notmatch '^PS'} | Where-Object {$_.Name -Like "MicrosoftEdge*"} | Select-Object -Expand Name)
                if ($microsoftEdgeAutoLaunchPropertyName) {
                    Remove-ItemProperty -Force -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $microsoftEdgeAutoLaunchPropertyName -ErrorAction SilentlyContinue
                }
            }
        }

        wdCoreEvalRule $options "Superfetch" @{
            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 0
            }
        }

        wdCoreEvalRule $options "WiFi Sense" @{
            "disable" = {
                wdCoreRegSet -Hive "HKLM" -Path "SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
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
}

Export-ModuleMember -Function wdSystemConfigureGeneral

function wdSystemPostprocess {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $profile
    )

    process {
        $options = $profile."Rules"."System Configuration"."Junk"
        if ($options -eq $null) {
            wdCoreLog "Profile does not have rules for: System Configuration / Junk"
            return
        }

        wdCoreEvalRule $options "Contacts (user profile)" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\Contacts") {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Contacts"
                }
            }
        }

        wdCoreEvalRule $options "Favorites (user profile)" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\Favorites") {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Favorites"
                }
            }
        }

        wdCoreEvalRule $options "Links (user profile)" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\Links") {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Links"
                }
            }
        }

        wdCoreEvalRule $options "SavedGames (user profile)" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\Saved Games") {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Saved Games"
                }
            }
        }

        wdCoreEvalRule $options "Searches (user profile)" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\Searches") {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$Env:USERPROFILE\Searches"
                }
            }
        }

        wdCoreEvalRule $options ".lesshst" @{
            "remove" = {
                if (Test-Path "$Env:USERPROFILE\.lesshst") {
                    Remove-Item -Force -ErrorAction SilentlyContinue "$Env:USERPROFILE\.lesshst"
                }
            }
        }
    }
}

Export-ModuleMember -Function wdSystemPostprocess
