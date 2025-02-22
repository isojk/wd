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
            if ((& $conutil.AskYesNo -Prompt "Do you want to configure explorer now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."System"."Explorer"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Explorer"
            return
        }

        $rules.EvalRule("Compact view mode", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 1
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Hidden files", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
            }
        })

        $rules.EvalRule("File extensions", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Path in title bar", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 1
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Creating Thumbs.db files on network volumes", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 0
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnailsOnNetworkFolders" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Search, Task, Widget, Chat and Copilot buttons", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 1
                #& $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 1
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
                #& $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Copilot service", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 0
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Widgets service", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("News and Interests", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKLM" -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
            }
        })

        <#
        $rules.EvalRule("Taskbar: Colors on Taskbar, Start, and SysTray", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 0
            }
        })
        #>

        <#
        $rules.EvalRule("Titlebar: Theme colors on titlebar", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 0
            }
        })
        #>

        $rules.EvalRule("Recycle Bin: Delete confirmation dialog", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 0
            }
        })

        $rules.EvalRule("Recycle Bin: Desktop icon", @{
            "show" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 0
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 0
            }

            "hide" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Align taskbar left", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 1
            }
        })

        $rules.EvalRule("Show recently added apps", @{
            "enable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 1
            }

            "disable" = {
                & $regutil.SetValue -Hive "HKCU" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "ShowRecentList" -Type DWord -Value 0
            }
        })

        & ConfigureContextMenu -Profile $Profile
    }
}

Export-ModuleMember -Function Configure

function ConfigureContextMenu {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null
    )

    process {
        $rules = $Profile."Rules"."System"."Explorer"."Context menu"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: System / Explorer / Context menu"
            return
        }

        # USE AT YOUR OWN RISK
        # @TODO figure out the original values of those keys

        $rules.EvalRuleSilently("Include in library", @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location"
                }
            }
        })

        $rules.EvalRuleSilently("Pin to Start", @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\PinToStartScreen"
                }
            }
        })

        $rules.EvalRuleSilently("Give access to", @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\*\ShellEx\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\ShellEx\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\PropertySheetHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Drive\shellex\PropertySheetHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing"
                }
            }
        })

        $rules.EvalRuleSilently("Scan with Microsoft Defender", @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\EPP"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP"
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\EPP"
                }
            }
        })

        $rules.EvalRuleSilently("Send To", @{
            "remove" = {
                foreach ($hive in @("HKCU", "HKLM")) {
                    & $regutil.DeleteKey -Hive $hive -Path "SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo"
                }
            }
        })
    }
}
