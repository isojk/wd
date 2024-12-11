[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_potplayer {    
    # @todo
    # https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe
}

function atn_personalize_potplayer {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
}

Export-ModuleMember -Function *
