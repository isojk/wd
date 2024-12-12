Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking

$APP_ID = "vscode"

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
                [Parameter(Position = 0, Mandatory = $true)] [object] $Profile
            )

            process {
                choco install -y vscode
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

                $vscode_source_userdata = "$Env:APPDATA\Code\User"
                $vscode_source_userdata_snippets = "$vscode_source_userdata\snippets"

                $vscode_target_userdata = "$data\vscode"
                $vscode_target_userdata_snippets = "$data\vscode\snippets"

                if ($Level -gt 0) {
                    # link snippets
                    wdCoreFSLink -Source $vscode_source_userdata_snippets -Target $vscode_target_userdata_snippets
                    
                    # link user settings
                    wdCoreFSLink -Source "$vscode_source_userdata\settings.json" -Target "$vscode_target_userdata\settings.json"
                    
                    # link user keybindings
                    wdCoreFSLink -Source "$vscode_source_userdata\keybindings.json" -Target "$vscode_target_userdata\keybindings.json"
                }

                if ($Level -gt 1) {
                    # Install extensions
                    vscode_install_extensions "$vscode_target_userdata\extensions"
                }
            }
        }
    }
}

Export-ModuleMember -Function hook

#
# Helpers
#

function vscode_load_extension_list {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Filename
    )

    process {
        (Get-Content "$Filename") | Where-Object { ![string]::IsNullOrWhiteSpace($_) -and !$_.Trim().StartsWith("#") } | Sort-Object
    }
}

function vscode_install_extensions {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Filename
    )

    process {
        vscode_load_extension_list $Filename | ForEach-Object { code --install-extension $_ }
    }
}

function vscode_uninstall_all_extensions {
    [CmdletBinding()]
    param ()

    process {
        (code --list-extensions) | ForEach-Object { code --uninstall-extension $_ --force }
    }
}
