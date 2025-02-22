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
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure privacy options now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Privacy options"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Privacy Options"
            return
        }

        $rules.EvalRule(".NET telemetry", @{
            "disable" = {
                [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "true", "User")
            }
        })

        $rules.EvalRule("Apps having ability to use advertising ID for experiences across apps", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
                & $regutil.DeleteKey -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Id"
            }
        })

        $rules.EvalRule("Tailored experiences with diagnostic data for current user", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Application launch tracking", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackProgs" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start-TrackDocs" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Activity history", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("SmartScreen filter for store apps", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Key logging & transmission to Microsoft", @{
            "disable" = {
                # Disabled when Telemetry is set to Basic
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Websites having ability to access language list", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("SmartGlass", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "UserAuthPolicy" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" -Name "BluetoothPolicy" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Suggested content in settings app", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338394Enabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338396Enabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Tips and suggestions for welcome and what's new", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Tips and suggestions when I use windows", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Start Menu: Suggested content", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Start Menu: Recommended", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Start Menu: Search entries", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Suggesting ways current user can finish setting up his device to get the most out of Windows", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Sync provider ads", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Automatic installation of suggested apps", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Suggested app notifications (Ads for MS services)", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" -Name "Enabled" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Showing suggestions for using mobile device with Windows (Phone Link suggestions)", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Mobility" -Name "OptedIn" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Speech, Inking, & Typing getting to know user", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Feedback: Windows asking for user feedback", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
                & $regutil.DeleteKey -Hive "HKCU" -Path "SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds"
            }
        })

        $rules.EvalRule("Feedback: Sending diagnostic and usage data", @{
            "disable" = {
                # Basic: 1, Enhanced: 2, Full: 3
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Block Outlook Preview from Outlook 365 in Windows registry", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -Name "HideNewOutlookToggle" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Bing Search widget", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Edge" -Name "WebWidgetAllowed" -Type DWord -Value 0

                $proc = Get-Process -Name "calc" -ErrorAction SilentlyContinue
                if ($null -ne $proc) {
                    Stop-Process -InputObject $proc
                }
            }
        })

        $rules.EvalRule("Defender: Cloud-Based Protection", @{
            "disable" = {
                # Enabled Advanced: 2, Enabled Basic: 1, Disabled: 0
                Set-MpPreference -MAPSReporting 0
            }
        })

        $rules.EvalRule("Defender: Automatic sample submission", @{
            "disable" = {
                # Prompt: 0, Auto Send Safe: 1, Never: 2, Auto Send All: 3
                Set-MpPreference -SubmitSamplesConsent 2
            }
        })

        $rules.EvalRule("Windows Recall", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("WiFi Sense", @{
            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
            }
        })

        & ConfigureCAM -Profile $Profile
    }
}

Export-ModuleMember -Function Configure

function ConfigureCAM {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null
    )

    process {
        $rules = $Profile."Rules"."System"."Privacy options"."Capability Access Manager"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Privacy Options / Capability Access Manager"
            return
        }

        $rules.EvalRule("App having access to account info", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to calendar", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to call history", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to camera", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to contacts", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to app diagnostics", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to documents", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to downloads", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to emails", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to filesystem", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to location", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to messaging", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to microphone", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to music library", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to notifications", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to phone calls", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to pictures", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to radios", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to screenshots", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" -Name "Value" -Type String -Value "Deny"
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to tasks", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having ability to share and sync with non-explicitly-paired wireless devices over uPnP", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" -Name "Value" -Type String -Value "Deny"
            }
        })

        $rules.EvalRule("App having access to videos", @{
            "deny" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Name "Value" -Type String -Value "Deny"
            }
        })
    }
}
