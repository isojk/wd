[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
param()

Import-Module $PSScriptRoot\core.psm1

function atn_load_profile_content ($id) {
    $dir = atn_core_get_profiles_dir
    $filename = "${id}.json"
    $fullpath = Join-Path -Path $dir -ChildPath $filename
    if (!(Test-Path $fullpath -PathType Leaf)) {
        atn_core_log_warning "File '${fullpath}' does not exist"
        return $null
    }

    Get-Content $fullpath | ConvertFrom-Json
}

function atn_load_profile ($id) {
    $base = atn_load_profile_content $id
    if ($base -eq $null) {
        atn_core_log_warning "Unable to load profile '${id}'"
        return $null
    }

    if (atn_core_object_hasproperty $base "Inherits") {
        $parent = atn_load_profile $base."Inherits"
        atn_core_object_merge $parent $base
        $base = $parent
    }

    $base
}

Export-ModuleMember -Function atn_load_profile
