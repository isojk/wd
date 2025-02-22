$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "VSCode"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Visual Studio Code"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne ((& $core.WhereIs "code") | Where-Object { $_.ToLower().Contains("microsoft vs code") })
    }
}

Export-ModuleMember -Function IsInstalled

function Install {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        & $mgmt.ChocoInstallPackage -Id "vscode"
    }
}

Export-ModuleMember -Function Install

function Configure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $Level = 0

        foreach ($arg in $CommandArgs) {
            switch ($arg.Key) {
                "Level" { $Level = $arg.Value }
            }
        }

        $appId = (& GetAppId)
        $data = (& $core.GetAppsPath)
        $private = (& $core.GetPrivateAppsPath)

        $vscode_source_userdata = "$Env:APPDATA\Code\User"
        $vscode_source_userdata_snippets = "$vscode_source_userdata\snippets"

        $vscode_target_userdata = "${data}\${appId}"
        $vscode_target_userdata_snippets = "${vscode_target_userdata}\snippets"

        if ($Level -ge 0) {
            if (-not (Test-Path $vscode_source_userdata)) {
                New-Item -ItemType Directory -Force -Path $vscode_source_userdata | Out-Null
            }

            if (-not (Test-Path $vscode_source_userdata_snippets)) {
                New-Item -ItemType Directory -Force -Path $vscode_source_userdata_snippets | Out-Null
            }

            # link snippets
            & $fsutil.Link -Source $vscode_source_userdata_snippets -Target $vscode_target_userdata_snippets
            
            # link user settings
            & $fsutil.Link -Source "$vscode_source_userdata\settings.json" -Target "$vscode_target_userdata\settings.json"
            
            # link user keybindings
            & $fsutil.Link -Source "$vscode_source_userdata\keybindings.json" -Target "$vscode_target_userdata\keybindings.json"
        }

        if ($Level -ge 1) {
            # Install extensions
            & InstallExtensions "$vscode_target_userdata\extensions"
        }
    }
}

Export-ModuleMember -Function Configure

function LoadExtensionList {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Filename
    )

    process {
        (Get-Content "$Filename") | Where-Object { ![string]::IsNullOrWhiteSpace($_) -and !$_.Trim().StartsWith("#") } | Sort-Object
    }
}

function InstallExtensions {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Filename
    )

    process {
        & LoadExtensionList $Filename | ForEach-Object { code --install-extension $_ }
    }
}

function UninstallAllExtensions {
    [CmdletBinding()]
    param ()

    process {
        (code --list-extensions) | ForEach-Object { code --uninstall-extension $_ --force }
    }
}
