[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_git ($profile) {
    # @TODO
}

function atn_personalize_git ($profile) {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    if (Test-Path "${Env:USERPROFILE}\.gitconfig") {
        Remove-Item -Path "${Env:USERPROFILE}\.gitconfig" -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path "${Env:USERPROFILE}\.gitconfig" -Target "$data\git\.gitconfig" | Out-Null

    # Change file attributes
    Get-Item "${Env:USERPROFILE}\.gitconfig" -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    if (Test-Path "${Env:USERPROFILE}\.local.gitconfig") {
        Get-Item "${Env:USERPROFILE}\.local.gitconfig" -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }
}

Export-ModuleMember -Function *
