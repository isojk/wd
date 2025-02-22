$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "UngoogledChromium"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Ungoogled Chromium"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne ((& $core.WhereIs "chrome") | Where-Object { $_.ToLower().Contains("chromium") })
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
        & $mgmt.GithubDownloadLatestRelease -Repository "ungoogled-software/ungoogled-chromium-windows" {
            $_.name.EndsWith("installer_x64.exe")
        }
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
        $ungchr_userdata = "${Env:LOCALAPPDATA}\Chromium\User Data\Default\"

        # link private bookmarks
        # @TODO
        if (Test-Path "${private}\${appId}") {
            & $fsutil.Link -Source "${ungchr_userdata}\Bookmarks" -Target "${private}\${appId}\Bookmarks.json"
        }
    }
}

Export-ModuleMember -Function Configure
