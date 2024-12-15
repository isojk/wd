$ErrorActionPreference = "Stop"

$BASEDIR = ".wd"
$BASEDIR_PRIVATE = ".wdp"

function wdCoreEnsureEnvironmentVars {
    $base = (wdCoreGetBasedir)
    $data = (wdCoreGetDataDir)

    # Set environment variable with path to app configuration files
    [Environment]::SetEnvironmentVariable("DOTFILES", "$data", "User")

    # Add wd to path
    wdCoreIncludeInEnvPath -Target "User" -Path $base
}

Export-ModuleMember -Function wdCoreEnsureEnvironmentVars

function wdChocoGetInstallDir {
    [CmdletBinding()]
    param()

    process {
        $dir = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "User")
        if ($dir -eq $null) {
            $dir = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine")
        }

        $dir
    }
}

Export-ModuleMember -Function wdChocoGetInstallDir

$CHOCO_HELPER_LOADED = $false

function wdRefreshEnv {
    [CmdletBinding()]
    param ()

    process {
        if ($CHOCO_HELPER -eq $null) {
            $chocoInstallDir = (wdChocoGetInstallDir)
            $chocoHelperModulePath = "${chocoInstallDir}/helpers/chocolateyProfile.psm1"
            Import-Module $chocoHelperModulePath -Force -DisableNameChecking -Scope Local
            $CHOCO_HELPER_LOADED = $true
        }

        refreshenv
    }
}

Export-ModuleMember -Function wdRefreshEnv

function wdCoreGetBasedir {
    [CmdletBinding()]
    param ()

    process {
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", $BASEDIR))
    }
}

Export-ModuleMember -Function wdCoreGetBasedir

function wdCoreGetProfilesDir {
    [CmdletBinding()]
    param ()

    process {
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("$(& wdCoreGetBasedir)", "profiles"))
    }
}

Export-ModuleMember -Function wdCoreGetProfilesDir

function wdCoreGetDataDir {
    [CmdletBinding()]
    param ()

    process {
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("$(& wdCoreGetBasedir)", "data"))
    }
}

Export-ModuleMember -Function wdCoreGetDataDir

function wdCoreGetPrivateBasedir {
    [CmdletBinding()]
    param ()

    process {
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", $BASEDIR_PRIVATE))
    }
}

function wdCoreGetPrivateDataDir {
    [CmdletBinding()]
    param ()

    process {
        wdCoreGetPrivateBasedir
    }
}

Export-ModuleMember -Function wdCoreGetPrivateDataDir

function wdCoreMergePSObjects {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $target,
        [Parameter(Position = 1, Mandatory = $true)] [object] $source
    )

    process {
        foreach ($p in $source.psobject.Properties) {
            if ($p.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and ($p.Name -in $target.PSobject.Properties.Name)) {
                wdCoreMergePSObjects $target."$($p.Name)" $p.Value
                continue;
            }

            $target | Add-Member -MemberType $p.MemberType -Name $p.Name -Value $p.Value -Force
        }
    }
}

Export-ModuleMember -Function wdCoreMergePSObjects

function wdCoreEvalRule {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $target,
        [Parameter(Position = 1, Mandatory = $true)] [string] $propertyName,
        [Parameter(Position = 2, Mandatory = $true)] [object] $ht
    )

    process {
        $defaultHandler = $null
        if ($ht.Contains("_")) {
            $defaultHandler = $ht."_"
        }

        if (!($propertyName -in $target.PSobject.Properties.Name)) {
            if ($defaultHandler -ne $null) {
                $defaultHandler.Invoke()
            }

            return
        }

        $value = $target."${propertyName}"
        if (!($value -is [string])) {
            if ($defaultHandler -ne $null) {
                $defaultHandler.Invoke()
            }

            return
        }

        $value = $value.Trim().ToLower()

        if ($ht.Contains($value)) {
            switch ($value) {
                "enable" {
                    wdCoreLog "Enable: ${propertyName}"
                }

                "disable" {
                    wdCoreLog "Disable: ${propertyName}"
                }

                "show" {
                    wdCoreLog "Show: ${propertyName}"
                }

                "hide" {
                    wdCoreLog "Hide: ${propertyName}"
                }

                "allow" {
                    wdCoreLog "Allow: ${propertyName}"
                }

                "deny" {
                    wdCoreLog "Deny: ${propertyName}"
                }

                "remove" {
                    wdCoreLog "Remove: ${propertyName}"
                }

                "remove_completely" {
                    wdCoreLog "Remove: ${propertyName}"
                }
            }

            #$ht."${value}".InvokeWithContext($null, [PSVariable]::New("_", $value))
            $ht."${value}".Invoke()
            return
        }

        if ($defaultHandler -ne $null) {
            $defaultHandler.Invoke()
        }
    }
}

Export-ModuleMember -Function wdCoreEvalRule

#
# Registry
#

$REG_HISTORY = @{}

function wdCoreTestRegValue {
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

function wdCoreRegGet {
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

Export-ModuleMember -Function wdCoreRegGet

function wdCoreRegSet {
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
            $hiveHistory = New-Object System.Collections.Generic.List[System.String]
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

Export-ModuleMember -Function wdCoreRegSet

function wdCoreRegDelete {
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

Export-ModuleMember -Function wdCoreRegDelete

#
# Miscellaneous
#

function wdCoreLogImpl {
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

function wdCoreLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        wdCoreLogImpl -Format $format -Args $args
    }
}

function wdCoreLogSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        wdCoreLogImpl -ForegroundColor "Green" -Format $format -Args $args
    }
}

function wdCoreLogWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    process {
        wdCoreLogImpl -ForegroundColor "Yellow" -Format $format -Args $args
    }
}

Export-ModuleMember -Function wdCoreLog
Export-ModuleMember -Function wdCoreLogSuccess
Export-ModuleMember -Function wdCoreLogWarning

function wdCoreWhere {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $name
    )

    process {
        (Get-Command $name -ErrorAction SilentlyContinue).Path
    }
}

Export-ModuleMember -Function wdCoreWhere

function wdCoreEnumEnvVars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string[]] $Target # Machine, User
    )
    
    # Machine: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    # User: HKEY_CURRENT_USER\Environment

    process {
        [Environment]::GetEnvironmentVariables($Target).GetEnumerator() | Sort-Object Name
    }
}

Export-ModuleMember -Function wdCoreEnumEnvVars

function wdCoreEnumEnvPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string[]] $Target,
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

Export-ModuleMember -Function wdCoreEnumEnvPath

function wdCoreIncludeInEnvPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Target,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    process {
        $needle = ((wdCoreEnumEnvPath -Target $Target) | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -like $Path })
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

Export-ModuleMember -Function wdCoreIncludeInEnvPath

function wdCoreFSMergeAttributes () {
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

Export-ModuleMember -Function wdCoreFSMergeAttributes

function wdCoreFSLink () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Source,
        [Parameter(Mandatory = $true)] [string] $Target
    )

    process {
        if (Test-Path $Source) {
            Remove-Item -Path $Source -Force | Out-Null
        }

        New-Item -ItemType SymbolicLink -Path $Source -Target $Target | Out-Null
    }
}

Export-ModuleMember -Function wdCoreFSLink

#
# App installation
#

