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
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure default applications now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Default apps"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Default apps"
            return
        }

        # 

        $rules.EvalRule("Microsoft OneDrive", @{
            "remove" = {
                & RemoveOneDrive -Force
            }
        })

        # MS Store

        $rules.EvalRule("Microsoft 3D Builder", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.3DBuilder"
            }
        })

        $rules.EvalRule("Microsoft Alarms and Clock", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsAlarms"
            }
        })

        $rules.EvalRule("Microsoft Bing Finance", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.BingFinance"
            }
        })

        $rules.EvalRule("Microsoft Bing News", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.BingNews"
            }
        })

        $rules.EvalRule("Microsoft Bing Search", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.BingSearch"
            }
        })

        $rules.EvalRule("Microsoft Bing Sports", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.BingSports"
            }
        })

        $rules.EvalRule("Microsoft Bing Weather", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.BingWeather"
            }
        })

        $rules.EvalRule("Microsoft Calendar and Mail", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsCommunicationsApps"
            }
        })

        $rules.EvalRule("Microsoft Cortana", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.549981C3F5F10"
            }
        })

        $rules.EvalRule("Microsoft Feedback Hub", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsFeedbackHub"
            }
        })

        $rules.EvalRule("Microsoft Get Office", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.MicrosoftOfficeHub"
            }
        })

        $rules.EvalRule("Microsoft Maps", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsMaps"
            }
        })

        $rules.EvalRule("Microsoft Messaging", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Messaging"
            }
        })

        $rules.EvalRule("Microsoft Mobile Plans", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.OneConnect"
            }
        })

        $rules.EvalRule("Microsoft OneNote", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Office.OneNote"
            }
        })

        $rules.EvalRule("Microsoft Outlook", @{
            "remove" = {
                & RemoveAppxPackage -Name "*OutlookForWindows*"
            }
        })

        <#
        $rules.EvalRule("Microsoft Paint", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Paint"
            }
        })
        #>

        $rules.EvalRule("Microsoft People", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.People"
            }
        })

        $rules.EvalRule("Microsoft Photos", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Windows.Photos"
            }
        })

        $rules.EvalRule("Microsoft Print 3D", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Print3D"
            }
        })

        $rules.EvalRule("Microsoft Quick Assist", @{
            "remove" = {
                & RemoveAppxPackage -Name "MicrosoftCorporationII.QuickAssist"
            }
        })

        $rules.EvalRule("Microsoft Skype", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.SkypeApp"
            }
        })

        $rules.EvalRule("Microsoft Solitaire", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.MicrosoftSolitaireCollection"
            }
        })

        $rules.EvalRule("Microsoft Sticky Notes", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.MicrosoftStickyNotes"
            }
        })

        $rules.EvalRule("Microsoft Sway", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Office.Sway"
            }
        })

        $rules.EvalRule("Microsoft Todos", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.ToDos"
            }
        })

        $rules.EvalRule("Microsoft Voice Recorder", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsSoundRecorder"
            }
        })

        $rules.EvalRule("Microsoft Xbox", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.Xbox.TCUI"
                & RemoveAppxPackage -Name "Microsoft.XboxApp"
                & RemoveAppxPackage -Name "Microsoft.XboxGameOverlay"
                & RemoveAppxPackage -Name "Microsoft.XboxGamingOverlay"
                & RemoveAppxPackage -Name "Microsoft.XboxIdentityProvider"
                & RemoveAppxPackage -Name "Microsoft.XboxSpeechToTextOverlay"
            }
        })

        $rules.EvalRule("Microsoft Your Phone", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.YourPhone"
            }
        })

        $rules.EvalRule("Microsoft Windows Media Player", @{
            "remove" = {
                Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
            }
        })

        <#
        $rules.EvalRule("Microsoft Windows Terminal", @{
            "remove" = {
                & RemoveAppxPackage -Name "Microsoft.WindowsTerminal"
            }
        })
        #>

        $rules.EvalRule("Adobe Creative Cloud Express", @{
            "remove" = {
                & RemoveAppxPackage -Name "*AdobeCreativeCloudExpress*"
            }
        })

        $rules.EvalRule("Amazon Prime Video", @{
            "remove" = {
                & RemoveAppxPackage -Name "AmazonVideo.PrimeVideo"
            }
        })

        $rules.EvalRule("Autodesk Sketch book", @{
            "remove" = {
                & RemoveAppxPackage -Name "*AutodeskSketchBook*"
            }
        })

        $rules.EvalRule("Bubble Witch 3 Saga", @{
            "remove" = {
                & RemoveAppxPackage -Name "*BubbleWitch3Saga*"
            }
        })

        $rules.EvalRule("Candy Crush Soda Saga", @{
            "remove" = {
                & RemoveAppxPackage -Name "*CandyCrushSodaSaga*"
            }
        })

        $rules.EvalRule("Clipchamp Video Editor", @{
            "remove" = {
                & RemoveAppxPackage -Name "Clipchamp.Clipchamp"
            }
        })

        $rules.EvalRule("Disney Magic Kingdoms", @{
            "remove" = {
                & RemoveAppxPackage -Name "*DisneyMagicKingdoms*"
            }
        })

        $rules.EvalRule("Disney+", @{
            "remove" = {
                & RemoveAppxPackage -Name "Disney.37853FC22B2CE"
            }
        })

        $rules.EvalRule("Dolby", @{
            "remove" = {
                & RemoveAppxPackage -Name "DolbyLaboratories.DolbyAccess"
            }
        })

        $rules.EvalRule("Facebook", @{
            "remove" = {
                & RemoveAppxPackage -Name "*Facebook*"
            }
        })

        $rules.EvalRule("Instagram", @{
            "remove" = {
                & RemoveAppxPackage -Name "*Instagram*"
            }
        })

        $rules.EvalRule("March of Empires", @{
            "remove" = {
                & RemoveAppxPackage -Name "*MarchofEmpires*"
            }
        })

        $rules.EvalRule("SlingTV", @{
            "remove" = {
                & RemoveAppxPackage -Name "*SlingTV*"
            }
        })

        $rules.EvalRule("Spotify", @{
            "remove" = {
                & RemoveAppxPackage -Name "*spotify*"
            }
        })

        $rules.EvalRule("TikTok", @{
            "remove" = {
                & RemoveAppxPackage -Name "*tiktok*"
            }
        })

        $rules.EvalRule("Twitter", @{
            "remove" = {
                & RemoveAppxPackage -Name "*twitter*"
            }
        })

        $rules.EvalRule("Zune Music", @{
            "remove" = {
                & RemoveAppxPackage -Name "*zunemusic*"
            }
        })

        $rules.EvalRule("Zune Video", @{
            "remove" = {
                & RemoveAppxPackage -Name "*zunevideo*"
            }
        })
    }
}

Export-ModuleMember -Function Configure

function RemoveAppxPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Name
    )

    process {
        Get-AppxPackage $Name | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppXProvisionedPackage -Online | Where DisplayName -Like $Name | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
}

function RemoveOneDrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [switch] $Force = $false
    )

    process {
        if ((& $conutil.AskYesNo -Prompt "This process will completely remove OneDrive from the system, removes integration in the explorer and resets all directories in user profile. Do you wish to proceed?" -DefaultValue "yes") -ne "yes") {
            return
        }

        # Stop OneDrive
        & $logger.Log "Stopping OneDrive"
        $p = Get-Process -Name "OneDrive.exe" -ErrorAction SilentlyContinue
        if ($null -ne $p) {
            Stop-Process -InputObject $p
        }

        # Uninstall OneDrive
        & $logger.Log "Uninstalling OneDrive"
        if (Test-Path "$Env:SystemRoot\System32\OneDriveSetup.exe") {
            & "$Env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
        }
        if (Test-Path "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
            & "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall
        }

        # Disable OneDrive via Group Policies
        & $logger.Log "Disabling OneDrive via Group Policies"
        & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

        # Remove OneDrive leftovers trash
        & $logger.Log "Removing OneDrive leftovers trash"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:LOCALAPPDATA\Microsoft\OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:ProgramData\Microsoft OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$Env:SystemDrive\OneDriveTemp"

        # Remove Onedrive from explorer sidebar
        & $logger.Log "Removing Onedrive from explorer sidebar"
        foreach ($hive in @("HKCU", "HKLM")) {
            foreach ($clspath in @("CLSID", "Wow6432Node\CLSID")) {
                foreach ($guid in @("{018D5C66-4533-4307-9B53-224DE2ED1FE6}", "{04271989-C4D2-BF67-95FE-120D1FD1EAE2}")) {
                    & $regutil.SetValue -Hive $hive -Path "Software\Classes\${clspath}\${guid}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 0
                    & $regutil.SetValue -Hive $hive -Path "Software\Classes\${clspath}\${guid}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 0
                }
            }
        }

        # Remove run option for new users
        # @todo needs an audit
        & $logger.Log "Removing run option for new users"
        reg load "hku\Default" "$Env:SystemDrive\Users\Default\NTUSER.DAT"
        & $regutil.DeleteKey -Hive "HKCU" -Path "Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup"
        reg unload "hku\Default"

        # Remove startmenu junk entry
        & $logger.Log "Removing startmenu junk entry"
        Remove-Item -Force -ErrorAction SilentlyContinue "$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

        #& $logger.Log "Starting explorer"
        #start "explorer.exe"
        #sleep 4

        # Remove additional OneDrive leftovers
        # @todo find out the correct way to do this
        #& $logger.Log "Removing additional OneDrive leftovers"
        #foreach ($item in (ls "$Env:windir\WinSxS\*onedrive*")) {
            #atn_core_takeown_folder $item.FullName
            #Remove-Item -Recurse -Force $item.FullName
        #}

        if (!(Test-Path "$Env:USERPROFILE\Desktop")) {
            & $logger.Log "Creating new directory: $Env:USERPROFILE\Desktop"
            New-Item -Path "$Env:USERPROFILE\Desktop" -Type "directory" | Out-Null
        }

        if (!(Test-Path "$Env:USERPROFILE\Documents")) {
            & $logger.Log "Creating new directory: $Env:USERPROFILE\Documents"
            New-Item -Path "$Env:USERPROFILE\Documents" -Type "directory" | Out-Null
        }

        if (!(Test-Path "$Env:USERPROFILE\Pictures")) {
            & $logger.Log "Creating new directory: $Env:USERPROFILE\Pictures"
            New-Item -Path "$Env:USERPROFILE\Pictures" -Type "directory" | Out-Null
        }

        & $logger.Log "Relinking user shell folders to canonical ones in user profile"

        $userShellFolders = @{
            "{0DDD015D-B06C-45D5-8C4C-F59713854639}" = "%USERPROFILE%\Pictures"
            "{374DE290-123F-4565-9164-39C4925E467B}" = "%USERPROFILE%\Downloads"
            "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" = "%USERPROFILE%\Documents"
            "Desktop" = "%USERPROFILE%\Desktop"
            "My Pictures" = "%USERPROFILE%\Pictures"
            "Personal" = "%USERPROFILE%\Documents"
        }

        $userShellFoldersRegPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

        foreach ($usf in $userShellFolders.GetEnumerator()) {
            $name = $usf.Key
            $value = $usf.Value

            & $regutil.SetValue -Hive "HKCU" -Path $userShellFoldersRegPath -Name $name -Type String -Value $value
        }

        # @todo make this step as safe as it can be
        <#
        $dirname = [Environment]::GetEnvironmentVariable("OneDrive", "User")
        if ($null -ne $dirname) {
            if (Test-Path "$dirname") {
                if (Test-Path "$dirname\Desktop") {
                    & $logger.Log "Moving directory: $dirname\Desktop"
                    Move-Item -Force "$dirname\Desktop\*" "$Env:USERPROFILE\Desktop"
                }

                if (Test-Path "$dirname\Documents") {
                    & $logger.Log "Moving directory: $dirname\Documents"
                    Move-Item -Force "$dirname\Documents\*" "$Env:USERPROFILE\Documents"
                }

                if (Test-Path "$dirname\Pictures") {
                    & $logger.Log "Moving directory: $dirname\Pictures"
                    Move-Item -Force "$dirname\Pictures\*" "$Env:USERPROFILE\Pictures"
                }

                #& $logger.Log "Removing directory: $dirname"
                #Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "$dirname"
            }
        }
        #>

        & $logger.Log "Remove OneDrive environment variables"
        [Environment]::SetEnvironmentVariable("OneDrive", $null, "User")
        [Environment]::SetEnvironmentVariable("OneDriveConsumer", $null, "User")
    }
}
