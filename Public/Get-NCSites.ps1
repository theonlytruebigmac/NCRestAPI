<#
.SYNOPSIS
Retrieves sites from the N-central API.

.DESCRIPTION
Supports retrieving all sites, sites under a specific customer, or a site by ID.
Accepts pipeline input - `Get-NCCustomers | Get-NCSites` yields every site under every customer.

.PARAMETER SiteId
Specific site to retrieve. Bound from pipeline by property name `siteId`.

.PARAMETER CustId
Customer whose sites should be listed. Bound from pipeline by property name `customerId`.

.PARAMETER All
Auto-paginate through the list endpoint.

.EXAMPLE
Get-NCSites -CustId 100

.EXAMPLE
Get-NCCustomers -All | Get-NCSites
#>
function Get-NCSites {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SiteId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('customerId')]
        [string]$CustId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc',
        [string]$Select
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        if ($SiteId) {
            Write-Verbose "[FUNCTION] Get-NCSites: api/sites/$SiteId"
            return $api.Get("api/sites/$SiteId")
        }

        $endpoint = if ($CustId) { "api/customers/$CustId/sites" } else { 'api/sites' }

        $queryParameters = @{}
        Add-NCCommonQuery -Parameters $queryParameters -Select $Select -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            Write-Verbose "[FUNCTION] Get-NCSites: paging $endpoint"
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCSites: $endpoint"
        $api.Get($endpoint)
    }
}
