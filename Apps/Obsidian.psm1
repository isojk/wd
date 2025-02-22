$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "Obsidian"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Obsidian"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "obsidian")
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
        & $mgmt.ChocoInstallPackage -Id "obsidian"
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

        <#
            @TODO

            Create directory ${Env:USERPROFILE}\Obsidian
            Create desktop.ini [-ahs] with contents:
                [.ShellClassInfo]
                IconResource=${Env:LOCALAPPDATA}\Programs\Obsidian\Obsidian.exe,0

        #>
    }
}

Export-ModuleMember -Function Configure
