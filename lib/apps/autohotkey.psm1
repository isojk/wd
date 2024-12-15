$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "autohotkey"

function hook {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $InstallationHandlers,
        [Parameter(Mandatory = $true)] [object] $ConfigurationHandlers
    )

    process {
        $InstallationHandlers[$APP_ID] = {
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true)] [object] $profile
            )

            process {
                wdGithubDownloadLatestRelease -Repository "AutoHotkey/AutoHotkey" {
                    $_.name.EndsWith("_setup.exe")
                }
            }
        }

        $ConfigurationHandlers[$APP_ID] = {
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true)] [object] $Profile,
                [Parameter(Mandatory = $false)] [int] $Level = 1
            )

            process {
                $data = (wdCoreGetDataDir)
                $private = (wdCoreGetPrivateDataDir)
                $ahk_default_filename = "AutoHotkey.ahk"

                # Suppress startup info
                wdCoreRegSet -Hive "HKCU" -Path "Software\AutoHotkey\Dash" -Name "SuppressIntro" -Type DWord -Value 1

                # Link default .ahk file to startup dir
                $startupdir = wdCoreRegGet -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup"
                wdCoreFSLink -Source "${startupdir}\${ahk_default_filename}" -Target "${data}\autohotkey\${ahk_default_filename}"

                # Restart autohotkey
                # Get-Process takes image file name without extension
                $p = Get-Process -Name "AutoHotkey64" -ErrorAction SilentlyContinue
                if ($null -ne $p) {
                    #Stop-Process -InputObject $p
                }

                # AutoHotkey appends /restart when running .ahk directly (registry class)
                # It is not neccessary to stop the process manually
                & "${startupdir}\${ahk_default_filename}"
            }
        }
    }
}

Export-ModuleMember -Function hook
