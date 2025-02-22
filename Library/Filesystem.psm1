$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function MergeAttributes () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Filename,
        [Parameter(Mandatory = $false)] [switch] $Hidden,
        [Parameter(Mandatory = $false)] [switch] $System
    )

    process {
        Get-Item $Filename -Force | ForEach-Object {
            if ($Hidden) {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
            }

            if ($System) {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::System
            }
        }
    }
}

Export-ModuleMember -Function MergeAttributes

function Link () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Source,
        [Parameter(Mandatory = $true)] [string] $Target
    )

    process {
        if (-not (Test-Path $Target)) {
            wdCoreLogWarning "Path ""${Target}"" does not exist"
            return
        }

        if (Test-Path $Source) {
            Remove-Item -Path $Source -Force -Recurse | Out-Null
        }

        New-Item -ItemType SymbolicLink -Path $Source -Target $Target | Out-Null
    }
}

Export-ModuleMember -Function Link
