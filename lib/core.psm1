[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

function atn_core_get_basedir {
    Join-Path -Path "${Env:USERPROFILE}" -ChildPath ".wd" -Resolve
}

Export-ModuleMember -Function atn_core_get_basedir

function atn_core_get_profiles_dir {
    Join-Path -Path "$(& atn_core_get_basedir)" -ChildPath "profiles" -Resolve
}

Export-ModuleMember -Function atn_core_get_profiles_dir

function atn_core_get_data_dir {
    Join-Path -Path "$(& atn_core_get_basedir)" -ChildPath "data" -Resolve
}

Export-ModuleMember -Function atn_core_get_data_dir

function atn_core_get_private_basedir {
    Join-Path -Path "${Env:USERPROFILE}" -ChildPath ".wdp" -Resolve
}

function atn_core_get_private_data_dir {
    atn_core_get_private_basedir
}

Export-ModuleMember -Function atn_core_get_private_data_dir




function atn_core_object_hasproperty ($target, $propertyName) {
    $propertyName -in $target.PSobject.Properties.Name
}

Export-ModuleMember -Function atn_core_object_hasproperty

function atn_core_object_merge ($target, $source) {
    foreach ($p in $source.psobject.Properties) {
        if ($p.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and (atn_core_object_hasproperty $target $p.Name)) {
            atn_core_object_merge $target."$($p.Name)" $p.Value
            continue;
        }

        $target | Add-Member -MemberType $p.MemberType -Name $p.Name -Value $p.Value -Force
    }
}

Export-ModuleMember -Function atn_core_object_merge


function atn_core_eval_rule ($target, [string] $propertyName, $ht) {
    $defaultHandler = $null
    if ($ht.Contains("_")) {
        $defaultHandler = $ht."_"
    }

    if (!(atn_core_object_hasproperty $target $propertyName)) {
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
                atn_core_log "Enable: ${propertyName}"
            }

            "disable" {
                atn_core_log "Disable: ${propertyName}"
            }

            "show" {
                atn_core_log "Show: ${propertyName}"
            }

            "hide" {
                atn_core_log "Hide: ${propertyName}"
            }

            "allow" {
                atn_core_log "Allow: ${propertyName}"
            }

            "deny" {
                atn_core_log "Deny: ${propertyName}"
            }

            "remove" {
                atn_core_log "Remove: ${propertyName}"
            }

            "remove_completely" {
                atn_core_log "Remove: ${propertyName}"
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

Export-ModuleMember -Function atn_core_eval_rule

#
# Registry
#

$REG_HISTORY = @{}

function atn_core_test_registry_value {
    [CmdletBinding()]
    param (
        [Alias("PSPath")] [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [string] $Path,
        [Parameter(Position = 1, Mandatory = $true)] [string] $Name,
        [switch] $PassThru
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

function atn_core_reg_set {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string] $Hive,
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $Name,
        [Parameter(Mandatory=$true)] [string] $Type,
        [Parameter(Mandatory=$true)] [object] $Value
    )

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

Export-ModuleMember -Function atn_core_reg_set

function atn_core_reg_remove_item {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string] $Hive,
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Name
    )

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

Export-ModuleMember -Function atn_core_reg_remove_item


#
# Miscellaneous
#

function atn_core_logbase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)] [string] $ForegroundColor,
        #[Parameter(Mandatory=$false)] [switch] $IsError,
        [Parameter(Mandatory=$true)] [string] $Format,
        [Parameter(Mandatory=$false)] [object[]] $Args
    )

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

function atn_core_log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    atn_core_logbase -Format $format -Args $args
}

function atn_core_log_success {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    atn_core_logbase -ForegroundColor "Green" -Format $format -Args $args
}

function atn_core_log_warning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)] [string] $format,
        [Parameter(ValueFromRemainingArguments = $true)] [object[]] $args
    )

    atn_core_logbase -ForegroundColor "Yellow" -Format $format -Args $args
}

Export-ModuleMember -Function atn_core_log
Export-ModuleMember -Function atn_core_log_success
Export-ModuleMember -Function atn_core_log_warning

function atn_core_where {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)] [string] $name
    )

    #where.exe $name
    return (Get-Command $name).Path
}

Export-ModuleMember -Function atn_core_where

function atn_core_enum_env_vars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [string[]] $Target # Machine, User
    )

    # Machine: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    # User: HKEY_CURRENT_USER\Environment

    return [Environment]::GetEnvironmentVariables($Target).GetEnumerator() | Sort-Object Name
}

Export-ModuleMember -Function atn_core_enum_env_vars

function atn_core_enum_env_path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [string[]] $Target,
        [Parameter(Mandatory=$false)] [switch] $Sort
    )

    $results = atn_core_enum_env_vars -Target $Target | Where-Object {$_.Name -eq "Path"} | Select-Object -ExpandProperty Value | ForEach-Object {$_.Split(";")} | Where-Object {$_.Length -gt 0}
    if ($Sort) {
        $results = $results | Sort-Object
    }

    return $results
}

Export-ModuleMember -Function atn_core_enum_env_path

