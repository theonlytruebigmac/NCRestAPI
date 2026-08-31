<#
.SYNOPSIS
Returns the list of discoverable endpoints under one of the root hypermedia nodes.

.DESCRIPTION
Covers six `_links` navigation endpoints:

  - default           -> GET /api            (top-level endpoint catalogue)
  - -AccessGroups     -> GET /api/access-groups
  - -CustomPsa        -> GET /api/custom-psa
  - -CustomPsaTickets -> GET /api/custom-psa/tickets
  - -ScheduledTasks   -> GET /api/scheduled-tasks
  - -StandardPsa      -> GET /api/standard-psa
  - -Users            -> GET /api/users

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
        [Parameter(ParameterSetName = 'Root')][switch]$Root,
        [Parameter(ParameterSetName = 'AccessGroups')][switch]$AccessGroups,
        [Parameter(ParameterSetName = 'CustomPsa')][switch]$CustomPsa,
        [Parameter(ParameterSetName = 'CustomPsaTickets')][switch]$CustomPsaTickets,
        [Parameter(ParameterSetName = 'ScheduledTasks')][switch]$ScheduledTasks,
        [Parameter(ParameterSetName = 'StandardPsa')][switch]$StandardPsa,
        [Parameter(ParameterSetName = 'Users')][switch]$Users
    )

    Write-Verbose "[FUNCTION] Get-NCApiLinks: invoked."
    $api = Get-NCRestApiInstance
    $endpoint = switch ($PSCmdlet.ParameterSetName) {
        'AccessGroups'     { 'api/access-groups' }
        'CustomPsa'        { 'api/custom-psa' }
        'CustomPsaTickets' { 'api/custom-psa/tickets' }
        'ScheduledTasks'   { 'api/scheduled-tasks' }
        'StandardPsa'      { 'api/standard-psa' }
        'Users'            { 'api/users' }
        default            { 'api' }
    }
    $api.Get($endpoint)
}
