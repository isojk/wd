$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Import-Module $PSScriptRoot\..\core.psm1 -DisableNameChecking -Scope Local
Import-Module $PSScriptRoot\..\essentials.psm1 -DisableNameChecking -Scope Local

$APP_ID = "sumatrapdf"

function hook {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [object] $InstallationHandlers,
        [Parameter(Mandatory = $true)] [object] $ConfigurationHandlers
    )

    process {
        $InstallationHandlers[$APP_ID] = {
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true)] [object] $profile
            )

            process {
                <#
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
                $req = Invoke-Webrequest -URI "https://www.sumatrapdfreader.org/download-free-pdf-viewer"
                $dom = New-Object -Com "HTMLFile"
                $dom.write([ref]$req.Content)

                #
                # Calling querySelectorAll can result in 0xc0000374 STATUS_HEAP_CORRUPTION

                $url = $null
                $dom.querySelector("a[href*='-64-install.exe']") | ForEach-Object {
                    $url = $_.getAttribute("href")
                }

                if ($null -eq $url) {
                    Write-Error "Could not obtain download URL for SumatraPDF"
                    return
                }

                if ($url.StartsWith("about:")) {
                    $url = $url.Substring(6)
                }

                if ($url.StartsWith("/")) {
                    $url = $url.Substring(1)
                }

                $url = "https://www.sumatrapdfreader.org/${url}"
                $filename = [System.IO.Path]::GetFileName($url)

                wdGenericInstallFromURL -AppId $APP_ID -Url $url -Filename $filename
                #>

                wdChocoInstallPackage -Id "sumatrapdf.install"
            }
        }

        $ConfigurationHandlers[$APP_ID] = {
            [CmdletBinding()]
            param (
                [Parameter(Position = 0, Mandatory = $true)] [object] $Profile,
                [Parameter(Mandatory = $false)] [int] $Level = 1
            )

            process {
                $data = (wdCoreGetDataDir)
                $private = (wdCoreGetPrivateDataDir)

                # @TODO
            }
        }
    }
}

Export-ModuleMember -Function hook
