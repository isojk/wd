[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_ungoogled_chromium {
}

function atn_personalize_ungoogled_chromium {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    #
    # Private
    #

    $ungchr_userdata = "${Env:LOCALAPPDATA}\Chromium\User Data\Default\"

    # links bookmarks

    if (Test-Path "${ungchr_userdata}\Bookmarks") {
        Remove-Item -Path "${ungchr_userdata}\Bookmarks" -Recurse -Force | Out-Null
    }
    
    New-Item -ItemType SymbolicLink -Path "${ungchr_userdata}\Bookmarks" -Target "${private}\ungoogled_chromium\bookmarks.json" | Out-Null
}

Export-ModuleMember -Function *
