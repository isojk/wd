$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function MergeAttributes () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Filename,
        [Parameter(Mandatory = $false)] $Hidden,
        [Parameter(Mandatory = $false)] $System
    )

    process {
        Get-Item $Filename -Force | ForEach-Object {
            if ($null -ne $Hidden) {
                if ($true -eq $Hidden) {
                    $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
                }
                else {
                    $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
                }
            }

            if ($null -ne $System) {
                if ($true -eq $System) {
                    $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::System
                }
                else {
                    $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::System)
                }
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
