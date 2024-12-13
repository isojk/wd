Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local

$APP_ID = "obsidian"

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
                choco install -y obsidian
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

                <#
                    @TODO

                    Create directory ${Env:USERPROFILE}\Obsidian
                    Create desktop.ini [-ahs] with contents:
                        [.ShellClassInfo]
                        IconResource=${Env:LOCALAPPDATA}\Programs\Obsidian\Obsidian.exe,0

                #>
            }
        }
    }
}

Export-ModuleMember -Function hook
