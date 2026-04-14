<#
.SYNOPSIS
Retrieves custom properties for an organization unit.

.DESCRIPTION
Returns all custom properties on an org unit, or a single property by ID. Supports `-All`
auto-pagination and pipeline input.

.EXAMPLE
Get-NCOrgProperty -OrgUnitId 1 -All

.EXAMPLE
Get-NCOrgProperty -OrgUnitId 1 -PropertyId 99
#>
function Get-NCOrgProperty {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PropertyId,

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
        if ($PropertyId) {
            return $api.Get("api/org-units/$OrgUnitId/custom-properties/$PropertyId")
        }

        $endpoint = "api/org-units/$OrgUnitId/custom-properties"

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
        Write-Verbose "[FUNCTION] Get-NCOrgProperty: $endpoint"
        $api.Get($endpoint)
    }
}
