<#
.SYNOPSIS
Retrieves service organizations from the N-central API.

.DESCRIPTION
Three modes:

  - default: `GET /api/service-orgs` - list every service organization (supports `-All`).
  - `-SoId X`: `GET /api/service-orgs/{soId}` - the service organization itself.
  - `-SoId X -Customers`: `GET /api/service-orgs/{soId}/customers` - customers under that SO
    (identical to `Get-NCCustomers -SoId X`, retained for discoverability).

Accepts pipeline input by property name `soId`.

.EXAMPLE
Get-NCServiceOrgs -All

.EXAMPLE
Get-NCServiceOrgs -SoId 1

.EXAMPLE
Get-NCServiceOrgs -SoId 1 -Customers
#>
function Get-NCServiceOrgs {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SoId,

        [switch]$Customers,

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
        if ($SoId -and -not $Customers) {
            return $api.Get("api/service-orgs/$SoId")
        }

        $endpoint = if ($SoId) { "api/service-orgs/$SoId/customers" } else { 'api/service-orgs' }

        $queryParameters = @{}
        if ($SortBy)                              { $queryParameters['sortBy']    = $SortBy }
        if ($SortOrder -and $SortOrder -ne 'asc') { $queryParameters['sortOrder'] = $SortOrder }

        if ($All) {
            Write-Verbose "[FUNCTION] Get-NCServiceOrgs: paging $endpoint"
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCServiceOrgs: $endpoint"
        $api.Get($endpoint)
    }
}
