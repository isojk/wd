[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_7zip {
    choco install -y 7zip.install
}

function atn_personalize_7zip {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)
}

Export-ModuleMember -Function *
