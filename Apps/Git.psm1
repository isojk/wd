$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$mgmt = ImportModuleAsObject "$PSScriptRoot\..\Library\AppManagement.psm1"

function GetAppId {
    process {
        "Git"
    }
}

Export-ModuleMember -Function GetAppId

function GetAppName {
    process {
        "Git"
    }
}

Export-ModuleMember -Function GetAppName

function IsInstalled {
    process {
        return $null -ne (& $core.WhereIs "git")
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
        # https://github.com/chocolatey-community/chocolatey-packages/blob/master/automatic/git.install/ARGUMENTS.md
        & $mgmt.ChocoInstallPackage -Id "git.install" -Params "/GitOnlyOnPath /WindowsTerminal /NoShellIntegration /NoCredentialManager /SChannel /Editor:VisualStudioCode"
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

        & $fsutil.Link -Source "${Env:USERPROFILE}\.gitconfig" -Target "$data\${appId}\.gitconfig"

        # Change file attributes
        & $fsutil.MergeAttributes -Filename "${Env:USERPROFILE}\.gitconfig" -Hidden
        if (Test-Path "${Env:USERPROFILE}\.local.gitconfig") {
            & $fsutil.MergeAttributes -Filename "${Env:USERPROFILE}\.local.gitconfig" -Hidden
        }
    }
}

Export-ModuleMember -Function Configure
