$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"

$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Console.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Env.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\..\Library\Logger.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

function IncludeShortcutsInPath {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $basepath = (& $core.GetBasePath)
        $dirname = "Shortcuts"
        $scpath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($basepath, $dirname))
        & $envutil.IncludeInPath -Target "User" -Path $scpath
    }
}

Export-ModuleMember -Function IncludeShortcutsInPath

$Commands = @{
    "IncludeShortcutsInPath" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & IncludeShortcutsInPath -Profile $Profile -CommandArgs $CommandArgs
        }
    }
}

function PrintHelp {
    [CmdletBinding(PositionalBinding = $false)]
    param()

    process {
        $subnames = New-Object "System.Collections.Generic.List[string]"
        foreach ($cmdkvp in $Commands.GetEnumerator()) {
            $cmdname = $cmdkvp.Key
            $cmdobj = $cmdkvp.Value

            $subnames.Add($cmdname) | Out-Null
        }

        $allSubnames = ([string]::Join("|", $subnames))

        Write-Host "Usage: wd Files <${allSubnames}>"
    }
}

function Configure {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] [switch] $Help = $false,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sub = $null

        foreach ($ca in $CommandArgs) {
            if ($ca.Key -eq $null -and $ca.Value -ne $null) {
                $sub = $ca.Value
                $CommandArgs.Remove($ca) | Out-Null
                break
            }
        }

        if (-not ($sub)) {
            if ($Help -eq $true) {
                & PrintHelp
                return
            }

            Write-Error "Missing subcommand"
            return
        }

        if (-not ($Commands.ContainsKey($sub))) {
            Write-Error "Unknown subcommand ""${sub}"""
            return
        }

        $cmdobj = $Commands["${sub}"]
        & $cmdobj.Action -Profile $Profile -CommandArgs $CommandArgs
    }
}

Export-ModuleMember -Function Configure
