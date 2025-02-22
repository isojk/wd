$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"


function GetAppId {
    process {
        "XnViewMP"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "XnView MP"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "xnviewmp")
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
        & $mgmt.ChocoInstallPackage -Id "xnviewmp"
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
        #$data = (& $core.GetAppsPath)
    }
}

Export-ModuleMember -Function Configure
