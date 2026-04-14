<#
.SYNOPSIS
Retrieves customers from the N-central API.

.DESCRIPTION
Supports retrieving all customers, customers under a service organization, or a specific
customer by ID. Accepts pipeline input so you can chain `Get-NCServiceOrgs | Get-NCCustomers`
or `Get-NCCustomers -All | Get-NCSites`.

.PARAMETER SoId
Service-organization ID whose customers should be listed.

.PARAMETER CustId
Specific customer ID to retrieve. Accepts pipeline input by the property name `customerId`
so `Get-NCCustomers -All | ForEach-Object { ... }` output can feed this parameter.

.PARAMETER All
Auto-paginate through the entire list endpoint.

.PARAMETER PageNumber
Page to retrieve (ignored when -All is used).

.PARAMETER PageSize
Items per page (ignored when -All is used).

.PARAMETER SortBy
Field to sort on.

.PARAMETER SortOrder
'asc' (default) or 'desc'.

.PARAMETER Select
Fields to include in the response.

.EXAMPLE
Get-NCCustomers -SoId 123

.EXAMPLE
Get-NCCustomers -All | Where-Object city -eq 'Austin'

.EXAMPLE
Get-NCServiceOrgs | Get-NCCustomers
#>
function Get-NCCustomers {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SoId,

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
        if ($CustId) {
            Write-Verbose "[FUNCTION] Get-NCCustomers: api/customers/$CustId"
            return $api.Get("api/customers/$CustId")
        }

        $endpoint = if ($SoId) { "api/service-orgs/$SoId/customers" } else { 'api/customers' }

        $queryParameters = @{}
        Add-NCCommonQuery -Parameters $queryParameters -Select $Select -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            Write-Verbose "[FUNCTION] Get-NCCustomers: paging $endpoint"
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCCustomers: $endpoint"
        $api.Get($endpoint)
    }
}
