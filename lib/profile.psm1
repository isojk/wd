Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

$ErrorActionPreference = "Stop"

function wdLoadProfileContent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id
    )

    process {
        $dir = wdCoreGetProfilesDir
        $filename = "${Id}.json"
        $fullpath = Join-Path -Path $dir -ChildPath $filename
        if (!(Test-Path $fullpath -PathType Leaf)) {
            wdCoreLogWarning "File '${fullpath}' does not exist"
            return $null
        }

        Get-Content $fullpath | ConvertFrom-Json
    }
}

function wdLoadProfile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id
    )

    process {
        $base = wdLoadProfileContent $Id
        if ($base -eq $null) {
            Write-Error "Unable to load profile '${Id}'"
            return $null
        }

        if ("Inherits" -in $base.PSobject.Properties.Name) {
            $parent = wdLoadProfile $base."Inherits"
            wdCoreMergePSObjects $parent $base
            $base = $parent
        }

        $base
    }
}

Export-ModuleMember -Function wdLoadProfile
