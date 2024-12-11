Import-Module $PSScriptRoot\lib\apps.psm1 -Force
Import-Module $PSScriptRoot\lib\core.psm1 -Force
Import-Module $PSScriptRoot\lib\pers.psm1 -Force
Import-Module $PSScriptRoot\lib\profile.psm1 -Force
Import-Module $PSScriptRoot\lib\system.psm1 -Force

$basedir = (atn_core_get_basedir)
$data = (atn_core_get_data_dir)
$private = (atn_core_get_private_data_dir)

[Environment]::SetEnvironmentVariable("DOTFILES", "$data", "User")

$profile = atn_load_profile "home"

#atn_system_configure_privacy $profile
#atn_system_configure_default_apps $profile
#atn_system_configure_general $profile
#atn_system_remove_junk $profile

#atn_system_personalize_general $profile
#atn_system_personalize_explorer $profile

#atn_eval_profile_apps $profile -PersonalizeOnly
