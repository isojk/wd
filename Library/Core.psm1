$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function GetBaseDirectoryName {
    [CmdletBinding()]
    param ()

    process {
        return ".wd"
    }
}

Export-ModuleMember -Function GetBaseDirectoryName

function GetPrivateBaseDirectoryName {
    [CmdletBinding()]
    param ()

    process {
        return ".wdp"
    }
}

Export-ModuleMember -Function GetPrivateBaseDirectoryName

function GetTempDirectoryName {
    [CmdletBinding()]
    param ()
    
    process {
        return ".wd"
    }
}

Export-ModuleMember -Function GetTempDirectoryName

function GetBasePath {
    [CmdletBinding()]
    param ()

    process {
        $dirname = (& GetBaseDirectoryName)
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", $dirname))
    }
}

Export-ModuleMember -Function GetBasePath

function GetPrivateBasePath {
    [CmdletBinding()]
    param ()

    process {
        $dirname = (& GetPrivateBaseDirectoryName)
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", $dirname))
    }
}

Export-ModuleMember -Function GetPrivateBasePath

function GetTempPath {
    [CmdletBinding()]
    param ()

    process {
        $dirname = (& GetTempDirectoryName)
        $tmp = [System.IO.Path]::GetTempPath()
        "${tmp}/${dirname}"
    }
}

Export-ModuleMember -Function GetTempPath

function GetAppsPath {
    [CmdletBinding()]
    param ()

    process {
        $path = (& GetBasePath)
        $dirname = "Apps"
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($path, $dirname))
    }
}

Export-ModuleMember -Function GetAppsPath

function GetPrivateAppsPath {
    [CmdletBinding()]
    param ()

    process {
        & GetPrivateBasePath
    }
}

Export-ModuleMember -Function GetPrivateAppsPath

function GetLinksPath {
    [CmdletBinding()]
    param ()

    process {
        $path = (& GetBasePath)
        $dirname = "Links"
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($path, $dirname))
    }
}

Export-ModuleMember -Function GetLinksPath

function GetProfilesPath {
    [CmdletBinding()]
    param ()

    process {
        $path = (& GetBasePath)
        $dirname = "Profiles"
        [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($path, $dirname))
    }
}

Export-ModuleMember -Function GetProfilesPath

function GetChocolateyInstallDir {
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

Export-ModuleMember -Function GetChocolateyInstallDir

function ParseRemainingArguments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [PSObject[]] $RemainingArgsLine = $null
    )

    process {
        $retval = New-Object "System.Collections.Generic.List[PSCustomObject]"
        if ($RemainingArgsLine -eq $null) {
            return $retval
        }

        $cache = New-Object "System.Collections.Generic.HashSet[string]"

        $last = $null
        foreach ($r in $RemainingArgsLine) {
            if ($r -match "^-(?<param>[^:]+):?$") {
                if ($last -ne $null) {
                    if (!$cache.Contains($last)) {
                        $retval.Add([PSCustomObject] @{
                            "Key" = "${last}"
                            "Value" = $true
                        }) | Out-Null

                        $cache.Add($last) | Out-Null
                    }
                }

                $last = "$($matches["param"])".Trim().ToLower()
            }
            else {
                if ($last -ne $null) {
                    if (!$cache.Contains($last)) {
                        $retval.Add([PSCustomObject] @{
                            "Key" = "${last}"
                            "Value" = $r
                        }) | Out-Null
                        
                        $cache.Add($last) | Out-Null
                    }

                    $last = $null
                }
                else {
                    $retval.Add([PSCustomObject] @{
                        "Key" = $null
                        "Value" = $r
                    }) | Out-Null
                }
            }
        }

        if ($last -ne $null) {
            if (!$cache.Contains($last)) {
                $retval.Add([PSCustomObject] @{
                    "Key" = "${last}"
                    "Value" = $true
                }) | Out-Null
            }
        }

        # This syntax is needed to prevent powershell implicitly unrolling arrays
        return , $retval
    }
}

Export-ModuleMember -Function ParseRemainingArguments

function MergeObjects {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [object] $target,
        [Parameter(Position = 1, Mandatory = $true)] [object] $source
    )

    process {
        foreach ($p in $source.PSObject.Properties) {
            if ($p.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and ($p.Name -in $target.PSObject.Properties.Name)) {
                MergeObjects $target."$($p.Name)" $p.Value
                continue;
            }

            $target | Add-Member -MemberType $p.MemberType -Name $p.Name -Value $p.Value -Force
        }
    }
}

Export-ModuleMember -Function MergeObjects

function GetLnkTarget {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $Path
    )

    process {
        $Path = "$Path".ToLower().Trim()

        $shell = $null
        try {
            $shell = New-Object -ComObject "WScript.Shell"
            $target = $shell.CreateShortcut($Path).TargetPath
            return $target
        }
        finally {
            if ($null -ne $shell) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
            }
        }
    }
}

Export-ModuleMember -Function GetLnkTarget

function WhereIs {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments = $true)] $names,
        [Parameter(Mandatory = $false)] [switch] $IncludeSystem
    )

    process {
        $results = New-Object "System.Collections.Generic.List[string]"

        foreach ($name in $names) {
            $result = (Get-Command $name -ErrorAction SilentlyContinue).Path
            if (($null -ne $result) -and ($result.Length -gt 0)) {
                $isSystem = ($result.ToLower().StartsWith("c:\windows"))

                if ((-not $isSystem) -or ($isSystem -and $IncludeSystem)) {
                    $results.Add($result) | Out-Null
                }
            }
        }

        if ($IncludeSystem) {
            if ($results.Count -eq 0) {
                return $null
            }

            return ,$results
        }

        foreach ($name in $names) {
            $result = (& GetStartMenuAppPath -ExecutableName $name)
            if (($null -ne $result) -and ($result.Length -gt 0)) {
                foreach ($r in $result) {
                    $results.Add($r) | Out-Null
                }
            }
        }

        if ($results.Count -eq 0) {
            return $null
        }

        return ,$results
    }
}

Export-ModuleMember -Function WhereIs

$HasCachedStartMenuTargets = $false
$CachedStartMenuTargets = New-Object "System.Collections.Generic.Dictionary[string, string]"

function PreloadStartMenuTargets {
    process {
        if ($false -eq $HasCachedStartMenuTargets) {
            $startMenuLocations = @(
                "C:\ProgramData\Microsoft\Windows\Start Menu",
                "C:\Users\isojk\AppData\Roaming\Microsoft\Windows\Start Menu"
            )

            $pathext_enm = ([System.Environment]::GetEnvironmentVariable("PATHEXT")).Split(";")
            $pathext = New-Object "System.Collections.Generic.HashSet[string]"
            foreach ($pe in $pathext_enm) {
                $pathext.Add($pe.ToLower().Trim()) | Out-Null
            }

            foreach ($sml in $startMenuLocations) {
                $lnks = (Get-ChildItem -Path $sml -Recurse -Include *.lnk -Attribute !Directory -Depth 8)
                $targets = $lnks | ForEach-Object { & GetLnkTarget -Path $_.FullName } #| ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToLower() }
                foreach ($target in $targets) {
                    $extension = ([System.IO.Path]::GetExtension($target))
                    if (($null -eq $extension) -or ($extension.Length -eq 0)) {
                        continue
                    }

                    if (-not $pathext.Contains($extension.ToLower())) {
                        continue
                    }

                    if ($target.ToLower().StartsWith("c:\windows")) {
                        continue
                    }

                    $filename = [System.IO.Path]::GetFileNameWithoutExtension($target).ToLower()
                    if ($CachedStartMenuTargets.ContainsKey($target)) {
                        continue;
                    }

                    $CachedStartMenuTargets.Add($target, $filename) | Out-Null
                }

                $HasCachedStartMenuTargets = $true
            }
        }
    }
}

function GetStartMenuAppPath {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [string] $ExecutableName
    )

    process {
        if ($false -eq $HasCachedStartMenuTargets) {
            & PreloadStartMenuTargets
        }

        $ExecutableName = $ExecutableName.ToLower().Trim()
        $results = @()
        foreach ($kvp in $CachedStartMenuTargets.GetEnumerator()) {
            $target = $kvp.Key
            $filename = $kvp.Value

            if ($ExecutableName -eq $filename) {
                $results += $target
            }
        }

        if ($results.Length -gt 0) {
            return $results
        }

        return $null
    }
}

Export-ModuleMember -Function GetStartMenuAppPath
