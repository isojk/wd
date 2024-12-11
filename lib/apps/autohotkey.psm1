[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_autohotkey {
}

function atn_personalize_autohotkey {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
    $ahk_default_filename = "AutoHotkey.ahk"

    # Suppress startup info
    atn_core_reg_set -Hive "HKCU" -Path "Software\AutoHotkey\Dash" -Name "SuppressIntro" -Type DWord -Value 1

    # Link default .ahk file to startup dir
    $startupdir = Get-ItemPropertyValue "HKCU:\\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "Startup"

    if (Test-Path "${startupdir}\${ahk_default_filename}") {
        Remove-Item -Path "${startupdir}\${ahk_default_filename}" -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path "${startupdir}\${ahk_default_filename}" -Target "${data}\autohotkey\${ahk_default_filename}" | Out-Null
}

Export-ModuleMember -Function *
