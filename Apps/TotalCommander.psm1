$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "TotalCommander"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Total Commander"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "totalcmd64" "totalcmd")
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
        & $mgmt.ChocoInstallPackage -Id "totalcommander"
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
        $totalcmd_appdata = "$Env:APPDATA\GHISLER"

        if (!(Test-Path $totalcmd_appdata)) {
            New-Item -Path $totalcmd_appdata -ItemType "directory" | Out-Null
        }

        & $fsutil.Link -Source "$totalcmd_appdata\wincmd.ini" -Target "$data\${appId}\wincmd.ini"
        & $fsutil.Link -Source "$totalcmd_appdata\usercmd.ini" -Target "$data\${appId}\usercmd.ini"
        & $fsutil.Link -Source "$totalcmd_appdata\default.bar" -Target "$data\${appId}\default.bar"
        & $fsutil.Link -Source "$totalcmd_appdata\vertical.bar" -Target "$data\${appId}\vertical.bar"

        # License key file
        # @TODO
        if (Test-Path "$private\${appId}") {
            & $fsutil.Link -Source "$totalcmd_appdata\WINCMD.KEY" -Target "$private\${appId}\WINCMD.KEY"
        }
    }
}

Export-ModuleMember -Function Configure
