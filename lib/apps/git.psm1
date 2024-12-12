[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_git ($profile) {
    # @TODO
}

function atn_personalize_git ($profile) {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    atn_core_fs_link -Source "${Env:USERPROFILE}\.gitconfig" -Target "$data\.gitconfig"

    # Change file attributes
    atn_core_fs_change_attributes -Filename "${Env:USERPROFILE}\.gitconfig" -Hidden
    if (Test-Path "${Env:USERPROFILE}\.local.gitconfig") {
        atn_core_fs_change_attributes -Filename "${Env:USERPROFILE}\.local.gitconfig" -Hidden
    }
}

Export-ModuleMember -Function *
