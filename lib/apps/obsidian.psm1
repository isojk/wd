[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_obsidian {
    choco install -y obsidian
}

function atn_personalize_obsidian {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    <#
        @todo
        Create directory ${Env:USERPROFILE}\Obsidian
        Create desktop.ini [-ahs] with contents:
            [.ShellClassInfo]
            IconResource=${Env:LOCALAPPDATA}\Programs\Obsidian\Obsidian.exe,0

    #>
}

Export-ModuleMember -Function *
