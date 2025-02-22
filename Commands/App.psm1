$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module "$PSScriptRoot\..\Library\ImportModuleAsObject.psm1"

$core = ImportModuleAsObject "$PSScriptRoot\..\Library\Core.psm1"
$conutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Console.psm1"
$envutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Env.psm1"
$logger = ImportModuleAsObject "$PSScriptRoot\..\Library\Logger.psm1"
$regutil = ImportModuleAsObject "$PSScriptRoot\..\Library\Registry.psm1"

$AppModuleCache = New-Object "System.Collections.Generic.Dictionary[string, PSCustomObject]"

function InstallApp {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $true)] [string] $AppId,
        [Parameter(Mandatory = $true)] $AppRules,
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] [bool] $Yes,
        [Parameter(Mandatory = $false)] [bool] $Force
    )

    process {
        $appModule = $null
        $abortOnExistingInstallation = $false

        if ($AppModuleCache.ContainsKey($AppId)) {
            #& $logger.Log "Loading app module {0}.psm1 from cache ..." $AppId
            $appModule = $AppModuleCache[$AppId]
        }
        else {
            $appModulePath = "${PSScriptRoot}\..\Apps\${AppId}.psm1"
            if (-not ([System.IO.File]::Exists($appModulePath))) {
                Write-Error "Module ""${appModulePath}"" does not exist"
                return $false
            }

            #& $logger.Log "Importing app module {0}.psm1 from ""{1}"" ..." $AppId $appModulePath
            $appModule = ImportModuleAsObject $appModulePath
            $AppModuleCache[$AppId] = $appModule
        }

        $appName = (& $appModule.GetAppName)

        if (-not (($true -eq $Yes) -or ($true -eq $Force))) {
            if ((& $conutil.AskYesNo -Prompt "Do you want to install application ""${appName}"" now?" -DefaultValue "yes") -ne "yes") {
                return $false
            }
        }

        $appIsInstalled = (& $appModule.IsInstalled)
        if ($true -eq $appIsInstalled) {
            if ($abortOnExistingInstallation) {
                & $logger.LogWarning "Application ""${appName}"" is already installed and available"
                return $true
            }
            else {
                if ($true -ne $Force) {
                    if ((& $conutil.AskYesNo -Prompt "Application ""${appName}"" is already installed and available. Continue with installation?" -DefaultValue "no") -ne "yes") {
                        return $true
                    }
                }
            }
        }

        & $logger.Log "Installing ""{0}"" ... " $appName

        $installationCommandArgs = [PSCustomObject] @{
            "Force" = $Force
        }

        & $appModule.Install -Profile $Profile -CommandArgs $installationCommandArgs
        return $true
    }
}

function ConfigureApp {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $true)] [string] $AppId,
        [Parameter(Mandatory = $true)] $AppRules,
        [Parameter(Mandatory = $false)] $Profile = $null
    )

    process {
        $appModule = $null

        if ($AppModuleCache.ContainsKey($AppId)) {
            #& $logger.Log "Loading app module {0}.psm1 from cache ..." $AppId
            $appModule = $AppModuleCache[$AppId]
        }
        else {
            $appModulePath = "${PSScriptRoot}\..\Apps\${AppId}.psm1"
            if (-not ([System.IO.File]::Exists($appModulePath))) {
                Write-Error "Module ""${appModulePath}"" does not exist"
                return $false
            }

            #& $logger.Log "Importing app module {0}.psm1 from ""{1}"" ..." $AppId $appModulePath
            $appModule = ImportModuleAsObject $appModulePath
            $AppModuleCache[$AppId] = $appModule
        }

        $appName = (& $appModule.GetAppName)
        $appIsInstalled = (& $appModule.IsInstalled)
        if ($false -eq $appIsInstalled) {
            & $logger.LogWarning "Application ""${appName}"" has not been installed yet"
            return $false
        }

        & $logger.Log "Configuring ""{0}"" ... " $appName

        $configureCommandsArgs = [PSCustomObject] @{}
        & $appModule.Configure -Profile $Profile -CommandArgs $configureCommandsArgs
        return $true
    }
}

function ExecuteInstallSubcommand {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $All = $false
        $Yes = $false
        $Force = $false
        $AppIds = New-Object "System.Collections.Generic.List[string]"
        foreach ($arg in $CommandArgs) {
            if ($null -eq $Arg.Key) {
                $AppIds.Add($Arg.Value) | Out-Null
                continue
            }

            switch ($arg.Key) {
                "All" { $All = $arg.Value }
                "Yes" { $Yes = $arg.Value }
                "Force" { $Force = $arg.Value }
            }
        }

        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        $rules = $Profile."Rules"."Applications"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for applications"
            return
        }

        # setup all applications listed in tool profile
        if ($true -eq $All) {
            $AppIds.Clear() | Out-Null
            foreach ($prop in $rules.PSObject.Properties) {
                $AppIds.Add($prop.Name) | Out-Null
            }
        }

        if ($AppIds.Count -eq 0) {
            Write-Error "Missing application id"
            return
        }

        foreach ($appId in $AppIds) {
            $appRules = $rules."$appId"
            if ($null -eq $appRules) {
                & $logger.LogWarning "Application id ""{0}"" not found in profile {1}" $appId $Profile.ID
                continue;
            }

            $doConfigure = (& InstallApp -AppId $appId -AppRules $appRules -Profile $Profile -Yes $Yes -Force $Force)
            if ($true -eq $doConfigure) {
                & ConfigureApp -AppId $appId -AppRules $appRules -Profile $Profile | Out-Null
            }
        }
    }
}

function ExecuteConfigureSubcommand {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $false)] $Profile = $null,
        [Parameter(Mandatory = $false)] $CommandArgs
    )

    process {
        $All = $false
        $AppIds = New-Object "System.Collections.Generic.List[string]"
        foreach ($arg in $CommandArgs) {
            if ($null -eq $Arg.Key) {
                $AppIds.Add($Arg.Value) | Out-Null
                continue
            }

            switch ($arg.Key) {
                "All" { $All = $arg.Value }
            }
        }

        if ($null -eq $Profile) {
            Write-Error "Missing tool profile"
            return
        }

        $rules = $Profile."Rules"."Applications"
        if ($null -eq $rules) {
            & $logger.LogWarning "Profile does not have rules for applications"
            return
        }

        # setup all applications listed in tool profile
        if ($true -eq $All) {
            $AppIds.Clear() | Out-Null
            foreach ($prop in $rules.PSObject.Properties) {
                $AppIds.Add($prop.Name) | Out-Null
            }
        }

        if ($AppIds.Count -eq 0) {
            Write-Error "Missing application id"
            return
        }

        foreach ($appId in $AppIds) {
            $appRules = $rules."$appId"
            if ($null -eq $appRules) {
                & $logger.LogWarning "Application id ""{0}"" not found in profile {1}" $appId $Profile.ID
                continue;
            }

            & ConfigureApp -AppId $appId -AppRules $appRules -Profile $Profile | Out-Null
        }
    }
}

$Commands = @{
    "Install" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ExecuteInstallSubcommand -Profile $Profile -CommandArgs $CommandArgs
        }
    }

    "Configure" = [PSCustomObject] @{
        "Action" = {
            [CmdletBinding(PositionalBinding = $false)]
            param(
                [Parameter(Mandatory = $false)] $Profile = $null,
                [Parameter(Mandatory = $false)] $CommandArgs
            )

            & ExecuteConfigureSubcommand -Profile $Profile -CommandArgs $CommandArgs
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

        Write-Host "Usage: wd App <${allSubnames}>"
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
