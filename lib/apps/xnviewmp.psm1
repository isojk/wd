[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_xnviewmp {
    choco install -y xnviewmp
}

function atn_personalize_xnviewmp {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
}

Export-ModuleMember -Function *
