$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "google_chrome"

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
                wdChocoInstallPackage -Id "googlechrome"
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

                $chrome_userdata = "${Env:LOCALAPPDATA}\Google\Chrome\User Data\Default\"

                # link private bookmarks
                # @TODO
                if (Test-Path "${private}\google_chrome") {
                    wdCoreFSLink -Source "${chrome_userdata}\Bookmarks" -Target "${private}\google_chrome\Bookmarks.json"
                }
            }
        }
    }
}

Export-ModuleMember -Function hook
