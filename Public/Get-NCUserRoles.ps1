<#
.SYNOPSIS
Retrieves user roles from the N-central API.

.DESCRIPTION
Returns all user roles scoped to an org unit, or a specific user role by ID.
Both require OrgUnitId because the underlying endpoint is
`/api/org-units/{orgUnitId}/user-roles[/{userRoleId}]`.

.EXAMPLE
Get-NCUserRoles -OrgUnitId 1 -All
#>
function Get-NCUserRoles {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('CustId', 'customerId')]
        [string]$OrgUnitId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserRoleId,

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
        if ($UserRoleId) {
            return $api.Get("api/org-units/$OrgUnitId/user-roles/$UserRoleId")
        }

        $endpoint = "api/org-units/$OrgUnitId/user-roles"

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
        Write-Verbose "[FUNCTION] Get-NCUserRoles: $endpoint"
        $api.Get($endpoint)
    }
}
