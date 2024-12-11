[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_total_commander {
    choco install -y totalcommander
}

function atn_personalize_total_commander {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
    $totalcmd_appdata = "$Env:APPDATA\GHISLER"

    if (!(Test-Path $totalcmd_appdata)) {
        New-Item -Path $totalcmd_appdata -ItemType "directory" | Out-Null
    }

    if (Test-Path "$totalcmd_appdata\wincmd.ini") {
        Remove-Item -Path "$totalcmd_appdata\wincmd.ini" -Force | Out-Null
    }

    if (Test-Path "$totalcmd_appdata\usercmd.ini") {
        Remove-Item -Path "$totalcmd_appdata\usercmd.ini" -Force | Out-Null
    }

    if (Test-Path "$totalcmd_appdata\default.bar") {
        Remove-Item -Path "$totalcmd_appdata\default.bar" -Force | Out-Null
    }

    if (Test-Path "$totalcmd_appdata\vertical.bar") {
        Remove-Item -Path "$totalcmd_appdata\vertical.bar" -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path "$totalcmd_appdata\wincmd.ini" -Target "$data\total_commander\wincmd.ini" | Out-Null
    New-Item -ItemType SymbolicLink -Path "$totalcmd_appdata\usercmd.ini" -Target "$data\total_commander\usercmd.ini" | Out-Null
    New-Item -ItemType SymbolicLink -Path "$totalcmd_appdata\default.bar" -Target "$data\total_commander\default.bar" | Out-Null
    New-Item -ItemType SymbolicLink -Path "$totalcmd_appdata\vertical.bar" -Target "$data\total_commander\vertical.bar" | Out-Null

    #
    # Private
    #

    if (Test-Path "$totalcmd_appdata\WINCMD.KEY") {
        Remove-Item -Path "$totalcmd_appdata\WINCMD.KEY" -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path "$totalcmd_appdata\WINCMD.KEY" -Target "$private\total_commander\WINCMD.KEY" | Out-Null
}

Export-ModuleMember -Function *
