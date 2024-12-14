Import-Module $PSScriptRoot\core.psm1 -DisableNameChecking -Scope Local

$ErrorActionPreference = "Stop"

function wdLoadProfileContent {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $id
    )

    process {
        $dir = wdCoreGetProfilesDir
        $filename = "${id}.json"
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
        [Parameter(Position = 0, Mandatory = $true)] [string] $id
    )

    process {
        $base = wdLoadProfileContent $id
        if ($base -eq $null) {
            wdCoreLogWarning "Unable to load profile '${id}'"
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
