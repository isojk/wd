#Requires -Version 3

[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory = $false, Position = 0)] [string] $Subcommand = $null,
    [Parameter(Mandatory = $false)] $Profile = $null,
    [Parameter(Mandatory = $false)] [switch] $Help = $false,
    [Parameter(Mandatory = $false)] [switch] $FirstRun = $false,
    [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)] [PSObject[]] $RemainingArgsLine
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Make sure a correct trace information is displayed upon an unhandled exception
trap { throw $Error[0] }

Import-Module "$PSScriptRoot\Library\ImportModuleAsObject.psm1" -Force

$systemModule = ImportModuleAsObject "$PSScriptRoot\Commands\System.psm1"
$filesModule = ImportModuleAsObject "$PSScriptRoot\Commands\Files.psm1"
$appModule = ImportModuleAsObject "$PSScriptRoot\Commands\App.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\Library\Core.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\Library\Logger.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\Library\Env.psm1"
$profutil = ImportModuleAsObject "$PSScriptRoot\Library\Profile.psm1"

$CommandArgs = (& $core.ParseRemainingArguments -RemainingArgsLine $RemainingArgsLine)

if (($Profile -ne $null) -and ($Profile.Length -gt 0)) {
    & $logger.Log "Loading tool profile ""${Profile}"" ..."
    $Profile = (& $profutil.LoadProfile -Id "${Profile}")
}

function escapeNull {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)] $value
    )

    process {
        if ($null -eq $value) {
            return "<null>"
        }

        return $value
    }
}

function ResetEnvVars {
    process {
        $appPath = (& $core.GetAppsPath)
        [Environment]::SetEnvironmentVariable("DOTFILES", $appPath, "User") | Out-Null
        & $envutil.RefreshEnvVars
    }
}

function IncludeItselfInPath {
    process {
        $basepath = (& $core.GetBasePath)
        & $envutil.IncludeInPath -Target "User" -Path $basepath
        & $envutil.RefreshEnvVars
    }
}

$Commands = @{
    "System" = [PSCustomObject] @{
        "Usage" = {
            return "See ""wd System -Help"" for more information"
        }

        "Action" = {
            if (-not (& $core.IsAdmin)) {
                Write-Error "You must execute this command with administrator privileges"
                exit 1
            }

            $sa = @{
                "Profile" = $Profile
                "Help" = $Help
            }

            & $systemModule.Configure -CommandArgs $CommandArgs @sa
        }
    }

    "Files" = [PSCustomObject] @{
        "Usage" = {
            return "See ""wd Files -Help"" for more information"
        }

        "Action" = {
            $sa = @{
                "Profile" = $Profile
                "Help" = $Help
            }

            & $filesModule.Configure -CommandArgs $CommandArgs @sa
        }
    }

    "App" = [PSCustomObject] @{
        "Usage" = {
            return "See ""wd App -Help"" for more information"
        }

        "Action" = {
            $sa = @{
                "Profile" = $Profile
                "Help" = $Help
            }

            & $appModule.Configure -CommandArgs $CommandArgs @sa
        }
    }

    "Where" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd Where <name>"
        }

        "Action" = {
            $names = @()

            foreach ($arg in $CommandArgs) {
                if ($null -eq $arg.Key) {
                    $names += $arg.Value
                    continue
                }
            }

            $whereis = (& $core.WhereIs @names)
            if ($null -ne $whereis) {
                $whereis
            }
        }
    }

    # @TODO this should be alias to Where, de-duplicate
    "WhereSystem" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd WhereSystem <name>"
        }

        "Action" = {
            $name = $null

            foreach ($arg in $CommandArgs) {
                if ($null -eq $arg.Key) {
                    $name = $arg.Value
                    continue
                }
            }

            if ($null -eq $name) {
                return;
            }

            $whereis = (& $core.WhereIs -IncludeSystem $name)
            if ($null -ne $whereis) {
                $whereis
            }
        }
    }

    "EnumEnvVars" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd EnumEnvVars [-Target <Machine|User>]"
        }

        "Action" = {
            $DEFAULT_TARGET = "User"

            $sa = @{
                "Target" = $DEFAULT_TARGET
            }

            foreach ($arg in $CommandArgs) {
                switch ($arg.Key) {
                    "Target" { $sa["Target"] = $arg.Value }
                }
            }

            & $envutil.EnumEnvVars @sa
        }
    }

    "EnumEnvPath" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd EnumEnvPath [-Target <Machine|User>] [-Sort]"
        }

        "Action" = {
            $DEFAULT_TARGET = "User"

            $sa = @{
                "Target" = $DEFAULT_TARGET
                "Sort" = $null
            }

            foreach ($arg in $CommandArgs) {
                switch ($arg.Key) {
                    "Target" { $sa["Target"] = $arg.Value }
                    "Sort" { $sa["Sort"] = $arg.Value }
                }
            }

            & $envutil.EnumEnvPath @sa
        }
    }

    "RefreshEnv" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd RefreshEnv"
        }

        "Action" = {
            & $envutil.RefreshEnvVars
        }
    }

    "ResetEnvVars" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd RefreshEnv"
        }

        "Action" = {
            & ResetEnvVars
        }
    }

    "IncludeItselfInPath" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd IncludeItselfInPath"
        }

        "Action" = {
            & IncludeItselfInPath
        }
    }

    "Debug" = [PSCustomObject] @{
        "Usage" = {
            return "Usage: wd Debug"
        }

        "Action" = {
            & choco install -y "paint.net"
        }
    }
}

if ($FirstRun) {
    & ResetEnvVars
    & IncludeItselfInPath
    $Help = $true
}

if (-not ($Subcommand)) {
    if ($Help -eq $true) {
        Write-Host "Available sub-commands:"
        foreach ($cmdkvp in $Commands.GetEnumerator()) {
            $cmdname = $cmdkvp.Key
            $cmdobj = $cmdkvp.Value

            $cmdUsage = (& $cmdobj.Usage)

            Write-Host "  ${cmdname}"
            Write-Host "    ${cmdUsage}"
        }

        exit 0
    }

    Write-Error "Missing subcommand"
    exit 1
}

# Resolve command line
if (-not ($Commands.ContainsKey($Subcommand))) {
    Write-Error "Command ""${Subcommand}"" does not exist"
    exit 1
}

$cmdobj = $Commands["${Subcommand}"]
& $cmdobj.Action
exit 0
