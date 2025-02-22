$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "GoogleChrome"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Google Chrome"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne ((& $core.WhereIs "chrome") | Where-Object { -not $_.ToLower().Contains("chromium") })
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
        & $mgmt.ChocoInstallPackage -Id "googlechrome"
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

        $chrome_userdata = "${Env:LOCALAPPDATA}\Google\Chrome\User Data\Default\"

        # link private bookmarks
        # @TODO
        if (Test-Path "${private}\${appId}") {
            & $fsutil.Link -Source "${chrome_userdata}\Bookmarks" -Target "${private}\${appId}\Bookmarks.json"
        }
    }
}

Export-ModuleMember -Function Configure
