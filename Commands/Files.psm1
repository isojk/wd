$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"

$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Console.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Env.psm1"
$fsutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Filesystem.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\..\Library\Logger.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

function IncludeShortcutsInPath {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $basepath = (& $core.GetBasePath)
        $dirname = "Shortcuts"
        $scpath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($basepath, $dirname))
        & $envutil.IncludeInPath -Target "User" -Path $scpath
    }
}

Export-ModuleMember -Function IncludeShortcutsInPath

function ExecuteUserProfileCommand {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs,
        [Parameter(Mandatory = $false)] [bool] $Yes = $false
    )

    process {
        if ($true -ne $Yes) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to reorganize user profile directory now?" -DefaultValue "yes") -ne "yes") {
                return
            }
        }

        $rules = $Profile."Rules"."Files"."User profile"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for: Files / User profile"
            return
        }

        # https://superuser.com/a/1470886
        <#
        Downloads   {374DE290-123F-4565-9164-39C4925E467B}  {7D83EE9B-2244-4E70-B1F5-5393042AF1E4}
        Music       My Music                                {A0C69A99-21C8-4671-8703-7934162FCF1D}
        Pictures    My Pictures                             {0DDD015D-B06C-45D5-8C4C-F59713854639}
        Videos      My Video                                {35286A68-3C57-41A1-BBB1-0EAE73D76C95}
        Documents   Personal                                {F42EE2D3-909F-4907-8871-4C22FC0BF756}
        #>

        $usfKeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

        $rules.EvalRule("Hide .ssh directory", @{
            "enable" = {
                $dir = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", ".ssh")))
                & $fsutil.MergeAttributes -Filename $dir -Hidden $true
            }
        })

        function removeUserProfileDirectory {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory = $true)] [string] $Name
            )

            process {
                $dir = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", $Name)))
                if (-not (Test-Path "${dir}")) {
                    return
                }

                if (Test-Path -Path "${dir}\*") {
                    if ((& $conutil.AskYesNo -Prompt "Directory ${dir} is not empty. Do you want to remove it?" -DefaultValue "no") -ne "yes") {
                        return
                    }
                }

                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${dir}"
            }
        }

        $rules.EvalRule("Remove Contacts directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Contacts"
            }
        })

        $rules.EvalRule("Remove Favorites directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Favorites"
            }
        })

        $rules.EvalRule("Remove Links directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Links"
            }
        })

        $rules.EvalRule("Remove Music directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Music"
            }
        })

        $rules.EvalRule("Remove Saved Games directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Saved Games"
            }
        })

        $rules.EvalRule("Remove Searches directory", @{
            "enable" = {
                removeUserProfileDirectory -Name "Searches"
            }
        })

        function unpin {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory = $true)] [string] $Guid
            )

            process {
                $qa = $null
                try {
                    $qa = New-Object -ComObject "Shell.Application";
                    $qa.Namespace("shell:::${Guid}").Self.InvokeVerb("UnpinToHome")
                }
                finally {
                    if ($null -ne $qa) {
                        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($qa) | Out-Null
                    }
                }
            }
        }

        $rules.EvalRule("Degrade Documents directory", @{
            "enable" = {
                $newName = "LegacyAppData"
                $newPath = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "${newName}")))

                $oldPath = (& $regutil.GetValue -Hive "HKCU" -Path $usfKeyName -Name "Personal")
                $oldPath = $oldPath.Replace("%USERPROFILE%", "${Env:USERPROFILE}")
                $oldName = ([System.IO.Path]::GetFileName($oldPath))

                if ($oldName -ne $newName) {
                    Rename-Item -Force -Path $oldPath -NewName $newName
                    & $regutil.SetValue -Hive "HKCU" -Path $usfKeyName -Name "Personal" -Type "String" -Value "%USERPROFILE%\${newName}"
                    & $regutil.SetValue -Hive "HKCU" -Path $usfKeyName -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Type "String" -Value "%USERPROFILE%\${newName}"
                }

                & $fsutil.MergeAttributes -Filename $newPath -Hidden $true

                $desktopIni = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${newPath}", "desktop.ini")))
                if (Test-Path $desktopIni) {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${desktopIni}"
                }
            }
        })

        $rules.EvalRule("Degrade Pictures directory", @{
            "enable" = {
                $newName = "Pictures"
                $newPath = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "${newName}")))

                #& $fsutil.MergeAttributes -Filename $newPath -Hidden $true

                <#
                $desktopIni = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${newPath}", "desktop.ini")))
                if (Test-Path $desktopIni) {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${desktopIni}"
                }
                #>
            }
        })

        $rules.EvalRule("Degrade Videos directory", @{
            "enable" = {
                $newName = "Videos"
                $newPath = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "${newName}")))

                #& $fsutil.MergeAttributes -Filename $newPath -Hidden $true

                <#
                $desktopIni = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${newPath}", "desktop.ini")))
                if (Test-Path $desktopIni) {
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${desktopIni}"
                }
                #>
            }
        })

        $downloadsRules = $rules."Downloads"
        if ($null -ne $downloadsRules) {
            $newPath = $downloadsRules."New location"
            if ($null -ne $newPath) {
                if (-not (Test-Path $newPath)) {
                    & $logger.LogWarning "Unable to relink Downloads: Target path ""{0}"" does not exist" $newPath
                }
                else {
                    & $logger.Log "Relinking Downloads to ""{0}""" $newPath
                    & $regutil.SetValue -Hive "HKCU" -Path $usfKeyName -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Type "String" -Value "${newPath}"
                    & $regutil.SetValue -Hive "HKCU" -Path $usfKeyName -Name "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" -Type "String" -Value "${newPath}"
                }
            }

            $degradeDefaultLocation = $downloadsRules."Degrade default location"
            if ($true -eq $degradeDefaultLocation) {
                $defaultPath = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "Downloads")))
                if (Test-Path $defaultPath) {
                    & $fsutil.MergeAttributes -Filename $defaultPath -Hidden $true
                }
            }
        }

        $rules.EvalRule("Remove recent -> automatic destinations", @{
            "enable" = {
                $dir = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations")))
                if (-not (Test-Path $dir)) {
                    return
                }

                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${dir}\*"                
            }
        })

        $rules.EvalRule("Remove recent -> custom destinations", @{
            "enable" = {
                $dir = ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine("${Env:USERPROFILE}", "AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations")))
                if (-not (Test-Path $dir)) {
                    return
                }

                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "${dir}\*"                
            }
        })
    }
}

$Commands = @{
    "IncludeShortcutsInPath" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & IncludeShortcutsInPath -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "UserProfile" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            $Yes = $false
            foreach ($arg in $CommandArgs) {
                switch ($arg.Key) {
                    "Yes" { $Yes = $arg.Value }
                }
            }

            & ExecuteUserProfileCommand -Profile $Profile -CommandArgs $CommandArgs -Yes $Yes
        }
    }
}

function PrintHelp {
    [CmdletBinding(PositionalBinding = $false)]
    param()

    process {
        $subnames = New-Object "System.Collections.Generic.List[string]"
        foreach ($cmdkvp in $Commands.GetEnumerator()) {
            $cmdname = $cmdkvp.Key
            $cmdobj = $cmdkvp.Value

            $subnames.Add($cmdname) | Out-Null
        }

        $allSubnames = ([string]::Join("|", $subnames))

        Write-Host "Usage: wd Files <${allSubnames}>"
    }
}

function Configure {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] [switch] $Help = $false,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $sub = $null

        foreach ($ca in $CommandArgs) {
            if ($ca.Key -eq $null -and $ca.Value -ne $null) {
                $sub = $ca.Value
                $CommandArgs.Remove($ca) | Out-Null
                break
            }
        }

        if (-not ($sub)) {
            if ($Help -eq $true) {
                & PrintHelp
                return
            }

            Write-Error "Missing subcommand"
            return
        }

        if (-not ($Commands.ContainsKey($sub))) {
            Write-Error "Unknown subcommand ""${sub}"""
            return
        }

        $cmdobj = $Commands["${sub}"]
        & $cmdobj.Action -Profile $Profile -CommandArgs $CommandArgs
    }
}

Export-ModuleMember -Function Configure
