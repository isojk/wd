[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_windows_terminal {
    winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
}

function atn_personalize_windows_terminal {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    $terminal_appdata = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $terminal_settings_filename = "settings.json"
    $terminal_dotfiles = "$data\windows_terminal"

    if (Test-Path "${terminal_appdata}\${terminal_settings_filename}") {
        Remove-Item -Path "${terminal_appdata}\${terminal_settings_filename}" -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path "${terminal_appdata}\${terminal_settings_filename}" -Target "${terminal_dotfiles}\${terminal_settings_filename}" | Out-Null
}

Export-ModuleMember -Function *
