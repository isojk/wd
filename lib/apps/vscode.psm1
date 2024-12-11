[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\..\core.psm1

function atn_install_vscode {
    choco install -y vscode
}

function atn_personalize_vscode {
    $data = (atn_core_get_data_dir)
    $private = (atn_core_get_private_data_dir)

    $vscode_source_userdata = "$Env:APPDATA\Code\User"
    $vscode_source_userdata_snippets = "$vscode_source_userdata\snippets"

    $vscode_target_userdata = "$data\vscode"
    $vscode_target_userdata_snippets = "$data\vscode\snippets"

    if (Test-Path $vscode_source_userdata_snippets) {
        Remove-Item -Path $vscode_source_userdata_snippets -Recurse -Force | Out-Null
    }
    
    New-Item -ItemType SymbolicLink -Path $vscode_source_userdata_snippets -Target $vscode_target_userdata_snippets | Out-Null

    if (Test-Path "$vscode_source_userdata\settings.json") {
        Remove-Item -Path "$vscode_source_userdata\settings.json" -Recurse -Force | Out-Null
    }
    
    New-Item -ItemType SymbolicLink -Path "$vscode_source_userdata\settings.json" -Target "$vscode_target_userdata\settings.json" | Out-Null

    if (Test-Path "$vscode_source_userdata\keybindings.json") {
        Remove-Item -Path "$vscode_source_userdata\keybindings.json" -Recurse -Force | Out-Null
    }
    
    New-Item -ItemType SymbolicLink -Path "$vscode_source_userdata\keybindings.json" -Target "$vscode_target_userdata\keybindings.json" | Out-Null

    # Install extensions
    vscode_install_extensions "$vscode_target_userdata\extensions"
}

function vscode_load_extension_list ($filename) {
    return (Get-Content "$filename") | Where-Object {![string]::IsNullOrWhiteSpace($_) -and !$_.Trim().StartsWith("#")} | Sort-Object
}

function vscode_install_extensions ($filename) {
    foreach ($extensionId in (vscode_load_extension_list $filename)) {
        code --install-extension $extensionId
    }
}

function vscode_uninstall_all_extensions {
    foreach ($extensionId in (code --list-extensions)) {
        code --uninstall-extension $extensionId --force
    }
}

Export-ModuleMember -Function *
