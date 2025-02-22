$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\ImportModuleAsObject.psm1"
$core = ImportModuleAsObject "$PSScriptRoot\Core.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\Logger.psm1"

function LoadProfileBase {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id
    )

    process {
        $dir = (& $core.GetProfilesPath)
        $filename = "${Id}.json"
        $fullpath = Join-Path -Path $dir -ChildPath $filename
        if (!(Test-Path $fullpath -PathType Leaf)) {
            & $logger.LogWarning "File '${fullpath}' does not exist"
            return $null
        }

        Get-Content $fullpath | ConvertFrom-Json
    }
}

function InstallMethods {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $Target
    )

    process {
        foreach ($prop in $Target.PSObject.Properties) {
            if ($prop.TypeNameOfValue -eq "System.Management.Automation.PSCustomObject") {
                & InstallMethods -Target $Target."$($prop.Name)"
                continue;
            }
        }

        if ($null -eq $Target.EvalRule) {
            Add-Member -InputObject $Target -MemberType ScriptMethod -Name "EvalRule" -Value {
                param (
                    [Parameter(Position = 1, Mandatory = $true)] [string] $PropertyName,
                    [Parameter(Position = 2, Mandatory = $true)] [object] $Callbacks
                )

                process {
                    $defaultHandler = $null
                    if ($Callbacks.Contains("_")) {
                        $defaultHandler = $Callbacks."_"
                    }

                    if (!($PropertyName -in $This.PSobject.Properties.Name)) {
                        if ($null -eq $defaultHandler) {
                            & $logger.LogWarning "Target is missing property ""{0}""" $PropertyName
                            return
                        }

                        $defaultHandler.Invoke()
                        return
                    }

                    $value = $This."${PropertyName}"
                    if (!($value -is [string])) {
                        if ($null -eq $defaultHandler) {
                            & $logger.LogWarning "Property ""{0}"" is not a string" $PropertyName
                            return
                        }

                        $defaultHandler.Invoke()
                        return
                    }

                    $value = $value.Trim().ToLower()

                    if ($Callbacks.Contains($value)) {
                        switch ($value) {
                            "enable" {
                                & $logger.Log "Enable: {0}" $PropertyName
                            }

                            "disable" {
                                & $logger.Log "Disable: {0}" $PropertyName
                            }

                            "show" {
                                & $logger.Log "Show: {0}" $PropertyName
                            }

                            "hide" {
                                & $logger.Log "Hide: {0}" $PropertyName
                            }

                            "allow" {
                                & $logger.Log "Allow: {0}" $PropertyName
                            }

                            "deny" {
                                & $logger.Log "Deny: {0}" $PropertyName
                            }

                            "remove" {
                                & $logger.Log "Remove: {0}" $PropertyName
                            }

                            "fullSetup" {
                                & $logger.Log "Full Setup: {0}" $PropertyName
                            }
                        }

                        #$Callbacks."${value}".InvokeWithContext($null, [PSVariable]::New("_", $value))
                        $Callbacks."${value}".Invoke()
                        return
                    }

                    if ($defaultHandler -ne $null) {
                        $defaultHandler.InvokeWithContext($null, [PSVariable]::New("_", $value))
                        #$defaultHandler.Invoke()
                    }
                }
            }

            Add-Member -InputObject $Target -MemberType ScriptMethod -Name "EvalRuleSilently" -Value {
                param (
                    [Parameter(Position = 1, Mandatory = $true)] [string] $PropertyName,
                    [Parameter(Position = 2, Mandatory = $true)] [object] $Callbacks
                )

                process {
                    if (!($PropertyName -in $This.PSobject.Properties.Name) -and ($null -eq $defaultHandler)) {
                        return
                    }

                    $This.EvalRule($PropertyName, $Callbacks)
                }
            }
        }
    }
}

function MergeProfileObjects {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $Target,
        [Parameter(Position = 1, Mandatory = $true)] [object] $Source
    )

    process {
        foreach ($prop in $Source.PSObject.Properties) {
            if ($prop.TypeNameOfValue -eq "System.Management.Automation.PSCustomObject" -and ($prop.Name -in $Target.PSObject.Properties.Name)) {
                MergeProfileObjects $Target."$($prop.Name)" $prop.Value
                continue;
            }

            $Target | Add-Member -MemberType $prop.MemberType -Name $prop.Name -Value $prop.Value -Force
        }
    }
}

function LoadProfile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Id
    )

    process {
        $base = (& LoadProfileBase $Id)
        if ($base -eq $null) {
            Write-Error "Unable to load tool profile ""${Id}"""
            return $null
        }

        if ("Inherits" -in $base.PSObject.Properties.Name) {
            $parent = (& LoadProfile $base."Inherits")
            & MergeProfileObjects $parent $base | Out-Null
            $base = $parent
        }

        & InstallMethods -Target $base
        $base
    }
}

Export-ModuleMember -Function LoadProfile
