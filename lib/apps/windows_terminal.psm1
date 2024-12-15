$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "windows_terminal"

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
                winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
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

                $terminal_appdata = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
                $terminal_settings_filename = "settings.json"
                $terminal_dotfiles = "$data\windows_terminal"

                # link terminal settings
                wdCoreFSLink -Source "${terminal_appdata}\${terminal_settings_filename}" -Target "${terminal_dotfiles}\${terminal_settings_filename}"
            }
        }
    }
}

Export-ModuleMember -Function hook

