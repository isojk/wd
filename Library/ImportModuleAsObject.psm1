$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function ImportModuleAsObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $Name
    )

    process {
        $module = Import-Module $Name -AsCustomObject -PassThru -Force -NoClobber -Scope Local
        $obj = [PSCustomObject] @{}
        #Add-Member -InputObject $obj -MemberType NoteProperty -Name "_Module" -Value $module

        $module | gm | Where-Object { $_.MemberType -eq "ScriptMethod" } | ForEach-Object {
            $func = Get-Command -Module $module -Name $_.Name
            Add-Member -InputObject $obj -MemberType NoteProperty -Name $_.Name -Value $func
        }

        return $obj
    }
}

Export-ModuleMember -Function ImportModuleAsObject
