<#
.SYNOPSIS
Retrieves organization units from the N-central API.

.DESCRIPTION
Retrieves all org units, a single org unit by ID, or its children. Supports `-All`
auto-pagination for the list endpoint and accepts pipeline input by property name `orgUnitId`.

.PARAMETER OrgUnitId
Org unit to retrieve (or whose children to retrieve, with `-Children`).

.PARAMETER Children
Return the children of the specified org unit instead of the unit itself.

.EXAMPLE
Get-NCOrgUnits -OrgUnitId 123 -Children
#>
function Get-NCOrgUnits {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OrgUnitId,

        [switch]$Children,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {

        Write-Verbose "[FUNCTION] Get-NCOrgUnits: invoked."
        if ($OrgUnitId -and $Children) {
            return $api.Get("api/org-units/$OrgUnitId/children")
        }
        if ($OrgUnitId) {
            return $api.Get("api/org-units/$OrgUnitId")
        }

        $endpoint = 'api/org-units'
        $queryParameters = @{}
        Add-NCCommonQuery -Parameters $queryParameters -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        $api.Get($endpoint)
    }
}
