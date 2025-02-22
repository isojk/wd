$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\Core.psm1"

$CHOCO_HELPER_LOADED = $false

function RefreshEnvVars {
    [CmdletBinding()]
    param ()

    process {
        if ($CHOCO_HELPER -eq $null) {
            $chocoInstallDir = (& $core.GetChocolateyInstallDir)
            $chocoHelperModulePath = "${chocoInstallDir}/helpers/chocolateyProfile.psm1"
            Import-Module $chocoHelperModulePath -Force -DisableNameChecking -Scope Local
            $CHOCO_HELPER_LOADED = $true
        }

        refreshenv
    }
}

Export-ModuleMember -Function RefreshEnvVars

function EnumEnvVars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Target # Machine, User
    )
    
    # Machine: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    # User: HKEY_CURRENT_USER\Environment

    process {
        [Environment]::GetEnvironmentVariables($Target).GetEnumerator() | Sort-Object Name
    }
}

Export-ModuleMember -Function EnumEnvVars

function EnumEnvPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Target,
        [Parameter(Mandatory = $false)] [switch] $Sort
    )

    process {
        $results = [Environment]::GetEnvironmentVariable("Path", $Target) | ForEach-Object {$_.Split(";")} | Where-Object {$_.Trim().Length -gt 0}
        if ($Sort) {
            $results = $results | Sort-Object
        }

        $results
    }
}

Export-ModuleMember -Function EnumEnvPath

function IncludeInPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Target,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    process {
        $needle = ((EnumEnvPath -Target $Target) | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -like $Path })
        if ($null -ne $needle) {
            return
        }

        $newpath = ([Environment]::GetEnvironmentVariable("Path", $Target).Trim())
        if ($newpath[$newpath.Length - 1] -ne ';') {
            $newpath += ';'
        }

        $newpath += $Path
        [Environment]::SetEnvironmentVariable("Path", $newpath, $Target)
    }
}

Export-ModuleMember -Function IncludeInPath

function EnsureEnvironmentVars {
    [CmdletBinding()]
    param ()

    process {
        $base = (& $core.GetBaseDirectory)
        $apps = (& $core.GetAppsDirectory)

        # Set environment variable with path to app configuration files
        [Environment]::SetEnvironmentVariable("DOTFILES", "$apps", "User")

        # Add wd to path
        IncludeInPath -Target "User" -Path $base

        RefreshEnv
    }
}

Export-ModuleMember -Function EnsureEnvironmentVars
