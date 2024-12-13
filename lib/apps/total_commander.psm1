Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local

$APP_ID = "total_commander"

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
                choco install -y totalcommander
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
                $totalcmd_appdata = "$Env:APPDATA\GHISLER"

                if (!(Test-Path $totalcmd_appdata)) {
                    New-Item -Path $totalcmd_appdata -ItemType "directory" | Out-Null
                }

                wdCoreFSLink -Source "$totalcmd_appdata\wincmd.ini" -Target "$data\total_commander\wincmd.ini"
                wdCoreFSLink -Source "$totalcmd_appdata\usercmd.ini" -Target "$data\total_commander\usercmd.ini"
                wdCoreFSLink -Source "$totalcmd_appdata\default.bar" -Target "$data\total_commander\default.bar"
                wdCoreFSLink -Source "$totalcmd_appdata\vertical.bar" -Target "$data\total_commander\vertical.bar"

                # License key file
                # @TODO
                if (Test-Path "$private\total_commander") {
                    wdCoreFSLink -Source "$totalcmd_appdata\WINCMD.KEY" -Target "$private\total_commander\WINCMD.KEY"
                }
            }
        }
    }
}

Export-ModuleMember -Function hook
