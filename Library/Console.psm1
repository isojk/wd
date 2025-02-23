$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function ClearCurrentConsoleLine {
    [CmdletBinding()]
    param (
    )

    process {
        $currentLineCursor = [System.Console]::CursorTop
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
        [System.Console]::Write(" " * [System.Console]::BufferWidth)
        [System.Console]::SetCursorPosition(0, $currentLineCursor)
    }
}

Export-ModuleMember -Function ClearCurrentConsoleLine

function AskYesNo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $Prompt,
        [Parameter(Mandatory = $true)] [string] $DefaultValue
    )

    process {
        $origCursorVisible = [System.Console]::CursorVisible
        [System.Console]::CursorVisible = $false

        $DefaultValueProcessed = $DefaultValue.Trim().ToLower()

        if (-not ($DefaultValueProcessed -eq "yes" -or $DefaultValueProcessed -eq "no")) {
            Write-Error "Unknown default value '${DefaultValue}'. Allowed values are: yes, no"
            [System.Console]::CursorVisible = $origCursorVisible
            return $null
        }

        $transl_yes = "Yes"
        $transl_no = "No"

        $erase = $false
        $selection = $DefaultValueProcessed

        $fc_yes = $transl_yes.ToLower()[0]
        $fc_no = $transl_no.ToLower()[0]

        $fc_yes_default = "y"
        $fc_no_default = "n"

        while ($true) {
            if ($erase) {
                ClearCurrentConsoleLine
            }

            $erase = $true

            $yes = $null
            if ($selection -eq "yes") {
                $yes = "[$($transl_yes.ToUpper())]"
            }
            else {
                $yes = " ${transl_yes} "
            }

            $no = $null
            if ($selection -eq "yes") {
                $no = " ${transl_no} "
            }
            else {
                $no = "[$($transl_no.ToUpper())]"
            }

            Write-Host -NoNewLine $prompt
            if ($selection -eq "yes") {
                Write-Host -NoNewLine -ForegroundColor Green " ${yes}"
            }
            else {
                Write-Host -NoNewLine " ${yes}"
            }

            if ($selection -eq "no") {
                Write-Host -NoNewLine -ForegroundColor Red " ${no}"
            }
            else {
                Write-Host -NoNewLine " ${no}"
            }

            $key = $Host.UI.RawUI.ReadKey()

            if ($null -eq $key) {
                continue
            }

            #
            # 13 = Enter
            # 37 = LeftArrow
            # 39 = RightArrow

            if ($key.VirtualKeyCode -eq 13) {
                break
            }

            if ($key.VirtualKeyCode -eq 37 -or (isChar $key $fc_yes) -or (isChar $key $fc_yes_default)) {
                $selection = "yes"
                continue
            }

            if ($key.VirtualKeyCode -eq 39 -or (isChar $key $fc_no) -or (isChar $key $fc_no_default)) {
                $selection = "no"
                continue
            }
        }

        Write-Host

        [System.Console]::CursorVisible = $origCursorVisible
        return $selection
    }
}

Export-ModuleMember -Function AskYesNo

function isChar {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)] [System.Management.Automation.Host.KeyInfo] $Key,
        [Parameter(Position = 1, Mandatory = $true)] [string] $Char
    )

    process {
        if ($null -eq $Key) {
            return $false
        }

        if ($Key.Character -eq $Char.ToLower()[0]) {
            return $true
        }

        if ($Key.Character -eq $Char.ToUpper()[0]) {
            return $true
        }
    }
}
