Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "ungoogled_chromium"

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
                # @TODO
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
                $ungchr_userdata = "${Env:LOCALAPPDATA}\Chromium\User Data\Default\"

                # link private bookmarks
                # @TODO
                if (Test-Path "${private}\ungoogled_chromium") {
                    wdCoreFSLink -Source "${ungchr_userdata}\Bookmarks" -Target "${private}\ungoogled_chromium\bookmarks.json"
                }
            }
        }
    }
}

Export-ModuleMember -Function hook
