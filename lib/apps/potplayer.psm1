$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "potplayer"

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
                wdGenericInstallFromURL -AppId $APP_ID -Url "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe" -Filename "PotPlayerSetup64.exe"
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
                # Nothing to work on yet
            }
        }
    }
}

Export-ModuleMember -Function hook
