$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "Keypirinha"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Keypirinha"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "keypirinha" "keypirinha-x64")
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
        & $mgmt.ChocoInstallPackage -Id "keypirinha"
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

        $app_data_basedir = "$Env:APPDATA\Keypirinha\User"
        $target_data_basedur = "$data\${appId}"

        if (-not (Test-Path $app_data_basedir)) {
            New-Item -ItemType Directory -Force -Path $app_data_basedir | Out-Null
        }
        
        # link Keypirinha.ini
        & $fsutil.Link -Source "$app_data_basedir\Keypirinha.ini" -Target "$target_data_basedur\Keypirinha.ini"

        # Restart
        $process = Get-Process -Name "keypirinha-x64" -ErrorAction SilentlyContinue
        if ($null -ne $process) {
            Stop-Process -InputObject $process
        }

        $image = (& $core.WhereIs "keypirinha")
        if ($null -ne $image) {
            & $image
        }
    }
}

Export-ModuleMember -Function Configure
