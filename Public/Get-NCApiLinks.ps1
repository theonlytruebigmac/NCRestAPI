<#
.SYNOPSIS
Returns the list of discoverable endpoints under one of the root hypermedia nodes.

.DESCRIPTION
Covers three `_links` navigation endpoints:

  - default           -> GET /api            (top-level endpoint catalogue)
  - -CustomPsa        -> GET /api/custom-psa
  - -CustomPsaTickets -> GET /api/custom-psa/tickets
  - -StandardPsa      -> GET /api/standard-psa

Prefer `Get-NCServerInfo` for root `/api` metadata. This cmdlet exists so the module
has explicit coverage for every spec endpoint.

.EXAMPLE
Get-NCApiLinks

.EXAMPLE
Get-NCApiLinks -StandardPsa
#>
function Get-NCApiLinks {
    [CmdletBinding(DefaultParameterSetName = 'Root')]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Parameters are discriminators consumed via ParameterSetName.')]
    param (
        [Parameter(ParameterSetName = 'CustomPsa')][switch]$CustomPsa,
        [Parameter(ParameterSetName = 'CustomPsaTickets')][switch]$CustomPsaTickets,
        [Parameter(ParameterSetName = 'StandardPsa')][switch]$StandardPsa
    )

    Write-Verbose "[FUNCTION] Get-NCApiLinks: invoked."
    $api = Get-NCRestApiInstance
    $endpoint = switch ($PSCmdlet.ParameterSetName) {
        'CustomPsa'        { 'api/custom-psa' }
        'CustomPsaTickets' { 'api/custom-psa/tickets' }
        'StandardPsa'      { 'api/standard-psa' }
        default            { 'api' }
    }
    $api.Get($endpoint)
}
