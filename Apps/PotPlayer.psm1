$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "PotPlayer"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "PotPlayer"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "potplayermini64" "potplayermini" "potplayer")
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
        & $mgmt.DownloadFromURLAndInstall -AppId $AppId -Url "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe" -Filename "PotPlayerSetup64.exe"
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
