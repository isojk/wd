[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_audacity {
    choco install -y audacity
}

function atn_personalize_audacity {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
}

Export-ModuleMember -Function *
