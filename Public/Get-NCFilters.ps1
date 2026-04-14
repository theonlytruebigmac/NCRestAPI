<#
.SYNOPSIS
Retrieves device filters from the N-central API.

.DESCRIPTION
Calls `/api/device-filters`. Supports `-All` auto-pagination.

.PARAMETER ViewScope
ALL or OWN_AND_USED. Default ALL.

.EXAMPLE
Get-NCFilters -All
#>
function Get-NCFilters {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [ValidateSet('ALL', 'OWN_AND_USED')]
        [string]$ViewScope = 'ALL',

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

    $api = Get-NCRestApiInstance
    $endpoint = 'api/device-filters'

    $queryParameters = @{}
    if ($ViewScope -and $ViewScope -ne 'ALL')   { $queryParameters['viewScope'] = $ViewScope }
    if ($Select)                                { $queryParameters['select']    = $Select }
    if ($SortBy)                                { $queryParameters['sortBy']    = $SortBy }
    if ($SortOrder -and $SortOrder -ne 'asc')   { $queryParameters['sortOrder'] = $SortOrder }

    if ($All) {
        return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
    }

    if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


    if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

    $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
    Write-Verbose "[FUNCTION] Get-NCFilters: $endpoint"
    $api.Get($endpoint)
}
