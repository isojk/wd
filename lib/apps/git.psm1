$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "git"

function hook {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [object] $InstallationHandlers = $null,
        [Parameter(Mandatory = $true)] [object] $ConfigurationHandlers
    )

    process {
        if ($null -ne $InstallationHandlers) {
            $InstallationHandlers[$APP_ID] = {
                [CmdletBinding()]
                param (
                    [Parameter(Position = 0, Mandatory = $true)] [object] $Profile
                )

                process {
                    # Installation covered in 'essentials' module
                    wdGitInstall
                }
            }
        }

        if ($null -ne $ConfigurationHandlers) {
            $ConfigurationHandlers[$APP_ID] = {
                [CmdletBinding()]
                param (
                    [Parameter(Position = 0, Mandatory = $true)] [object] $Profile,
                    [Parameter(Mandatory = $false)] [int] $Level = 1
                )

                process {
                    $data = (wdCoreGetDataDir)
                    $private = (wdCoreGetPrivateDataDir)

                    wdCoreFSLink -Source "${Env:USERPROFILE}\.gitconfig" -Target "$data\.gitconfig"

                    # Change file attributes
                    wdCoreFSMergeAttributes -Filename "${Env:USERPROFILE}\.gitconfig" -Hidden
                    if (Test-Path "${Env:USERPROFILE}\.local.gitconfig") {
                        wdCoreFSMergeAttributes -Filename "${Env:USERPROFILE}\.local.gitconfig" -Hidden
                    }
                }
            }
        }
    }
}

Export-ModuleMember -Function hook
