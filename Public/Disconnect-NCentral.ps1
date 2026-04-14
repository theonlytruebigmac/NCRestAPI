<#
.SYNOPSIS
Tears down the active N-central connection and clears cached tokens.

.EXAMPLE
Disconnect-NCentral
#>
function Disconnect-NCentral {
    [CmdletBinding()]
    param ()
    Get-NCRestApiInfo -Kill
}
