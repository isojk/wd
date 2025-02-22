$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

function GetAppId {
    process {
        "AutoHotkey"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "AutoHotkey"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "ahk" "autohotkey")
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
        & $mgmt.GithubDownloadLatestRelease -Repository "AutoHotkey/AutoHotkey" {
            $_.name.EndsWith("_setup.exe")
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
        $ahk_default_filename = "AutoHotkey.ahk"

        # Suppress startup info
        & $regutil.SetValue -Hive "HKCU" -Path "Software\AutoHotkey\Dash" -Name "SuppressIntro" -Type DWord -Value 1

        # Link default .ahk file to startup dir
        $startupdir = (& $regutil.GetValue -Hive "HKCU" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup")
        & $fsutil.Link -Source "${startupdir}\${ahk_default_filename}" -Target "${data}\${appId}\${ahk_default_filename}"

        # Restart autohotkey
        # Get-Process takes image file name without extension
        $p = Get-Process -Name "AutoHotkey64" -ErrorAction SilentlyContinue
        if ($null -ne $p) {
            #Stop-Process -InputObject $p
        }

        # AutoHotkey appends /restart when running .ahk directly (registry class)
        # It is not neccessary to stop the process manually
        & "${startupdir}\${ahk_default_filename}"
    }
}

Export-ModuleMember -Function Configure
