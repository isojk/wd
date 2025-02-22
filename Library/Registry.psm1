$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$REG_HISTORY = @{}

function TestValue {
    [CmdletBinding()]
    param (
        [Alias("PSPath")] [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [string] $Path,
        [Parameter(Position = 1, Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $false)] [switch] $PassThru
    )

    process {
        if (!(Test-Path $Path)) {
            return $false
        }

        $Key = Get-Item -LiteralPath $Path
        if ($Key.GetValue($Name, $null) -eq $null) {
            return $false
        }

        if ($PassThru) {
            return Get-ItemProperty $Path $Name
        }
        
        return $true
    }
}

Export-ModuleMember -Function TestValue

function GetValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Hive,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    process {
        Get-ItemPropertyValue "${Hive}:\\${Path}" "${Name}"
    }
}

Export-ModuleMember -Function GetValue

function SetValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Hive,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [string] $Type,
        [Parameter(Mandatory = $true)] [object] $Value
    )

    process {
        $hiveHistory = $null
        if ($REG_HISTORY.Contains($Hive)) {
            $hiveHistory = $REG_HISTORY[$Hive]
        }
        else {
            $hiveHistory = New-Object "System.Collections.Generic.List[string]"
            $REG_HISTORY[$Hive] = $hiveHistory
        }

        #if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {
        #    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null
        #}

        $joined = $null
        foreach ($segment in $Path.Split("\")) {
            if ($segment.Trim().Length -eq 0) {
                continue
            }

            if ($joined -eq $null) {
                $joined = $segment
            }
            else {
                $joined = "${joined}\${segment}"
            }

            $joinedWithHive = "${Hive}:\${joined}"

            if ($joined -in $hiveHistory) {
                continue
            }

            if (!(Test-Path $joinedWithHive)) {
                New-Item -Path $joinedWithHive -Type Folder | Out-Null
            }

            $hiveHistory.Add($joined)
        }

        Set-ItemProperty -Path "${Hive}:\${joined}" -Name $Name -Type $Type -Value $Value
    }
}

Export-ModuleMember -Function SetValue

function DeleteKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Hive,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $false)] [string] $Name
    )

    process {
        $joined = $null
        foreach ($segment in $Path.Split("\")) {
            if ($segment.Trim().Length -eq 0) {
                continue
            }

            if ($joined -eq $null) {
                $joined = $segment
            }
            else {
                $joined = "${joined}\${segment}"
            }
        }

        if ($Name -eq $null) {
            Remove-ItemProperty -Force -LiteralPath "${Hive}:\${joined}" -ErrorAction SilentlyContinue
            return
        }

        Remove-ItemProperty -Force -LiteralPath "${Hive}:\${joined}" -Name $Name -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember -Function DeleteKey
