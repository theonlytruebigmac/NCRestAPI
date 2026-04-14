<#
.SYNOPSIS
Tears down the active N-central connection and clears cached tokens.

.EXAMPLE
Disconnect-NCentral
#>
function Disconnect-NCentral {
    [CmdletBinding()]
    param ()
    Write-Verbose "[FUNCTION] Disconnect-NCentral: invoked."
    Get-NCRestApiInfo -Kill
}
