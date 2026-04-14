<#
.SYNOPSIS
Retrieves users from the N-central API.

.DESCRIPTION
Returns all users, or users scoped to an org unit (uses `/api/org-units/{id}/users`).
Supports `-All` auto-pagination and accepts pipeline input on `CustId` (aliased to `customerId`
and `orgUnitId`).

.EXAMPLE
Get-NCUsers -All
#>
function Get-NCUsers {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('customerId', 'orgUnitId')]
        [string]$CustId,

        [int]$FilterId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$Select,
        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        # /api/users is a hypermedia navigation endpoint (returns only _links).
        # Default to the system-level org unit when no customer/org scope is supplied.
        $unit = if ($CustId) { $CustId } else { 1 }
        $endpoint = "api/org-units/$unit/users"

        $queryParameters = @{}
        if ($FilterId)                            { $queryParameters['filterId']  = $FilterId }
        if ($Select)                              { $queryParameters['select']    = $Select }
        if ($SortBy)                              { $queryParameters['sortBy']    = $SortBy }
        if ($SortOrder -and $SortOrder -ne 'asc') { $queryParameters['sortOrder'] = $SortOrder }

        if ($All) {
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCUsers: $endpoint"
        $api.Get($endpoint)
    }
}
