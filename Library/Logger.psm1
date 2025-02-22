$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\Core.psm1"

function PrintImpl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [string] $ForegroundColor,
        #[Parameter(Mandatory = $false)] [switch] $IsError,
        [Parameter(Mandatory = $true)] [string] $Format,
        [Parameter(Mandatory = $false)] [object[]] $Args
    )

    process {
        $result = $null
        if ($Args -eq $null) {
            $result = [string]::Format($Format)
        }
        else {
            $result = [string]::Format($Format, $Args)
        }

        <#
        if ($IsError) {
            Write-Error $result
            return
        }
        #>

        if ($ForegroundColor) {
            Write-Host $result -ForegroundColor $ForegroundColor
        }
        else {
            Write-Host $result
        }
    }
}

function Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        PrintImpl -Format $format -Args $args
    }
}

function LogSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        PrintImpl -ForegroundColor "Green" -Format $format -Args $args
    }
}

function LogWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        PrintImpl -ForegroundColor "Yellow" -Format $format -Args $args
    }
}

Export-ModuleMember -Function Log
Export-ModuleMember -Function LogSuccess
Export-ModuleMember -Function LogWarning
