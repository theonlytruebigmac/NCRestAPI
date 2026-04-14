<#
.SYNOPSIS
Retrieves access groups from the N-central API.

.DESCRIPTION
Returns access groups for an org unit, a specific access group by ID, or all access groups
across a tenant when neither ID is supplied. Supports `-All` auto-pagination and pipeline input.

.PARAMETER OrgUnitId
Org unit whose access groups should be listed.

.PARAMETER AccessGroupId
Specific access group to retrieve.

.EXAMPLE
Get-NCAccessGroups -OrgUnitId 1 -All
#>
function Get-NCAccessGroups {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OrgUnitId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AccessGroupId,

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
        if ($AccessGroupId) {
            return $api.Get("api/access-groups/$AccessGroupId")
        }

        # /api/access-groups is a hypermedia navigation endpoint (returns only _links).
        # Default to the system-level org unit when no scope is supplied.
        $unit = if ($OrgUnitId) { $OrgUnitId } else { 1 }
        $endpoint = "api/org-units/$unit/access-groups"

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
        $api.Get($endpoint)
    }
}
