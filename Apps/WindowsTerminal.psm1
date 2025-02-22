$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"


function GetAppId {
    process {
        "WindowsTerminal"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Windows Terminal"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        # @TODO
        # Detecting "wt" is the only way I am aware of
        # I'm not sure how reliable it is
        return $null -ne (& $core.WhereIs "wt")
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
        & winget install --id "Microsoft.WindowsTerminal" -e --accept-package-agreements --accept-source-agreements
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
        $appId = (& GetAppId)
        $data = (& $core.GetAppsPath)
        $private = (& $core.GetPrivateAppsPath)

        $terminal_appdata = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        $terminal_settings_filename = "settings.json"
        $terminal_dotfiles = "$data\${appId}"

        # link terminal settings
        & $fsutil.Link -Source "${terminal_appdata}\${terminal_settings_filename}" -Target "${terminal_dotfiles}\${terminal_settings_filename}"
    }
}

Export-ModuleMember -Function Configure
