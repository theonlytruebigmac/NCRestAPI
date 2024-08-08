<#
.SYNOPSIS
Retrieves sites from the N-central API.

.DESCRIPTION
The `Get-NCSites` function retrieves sites from the N-central API.
It supports retrieving sites by customer ID or site ID and includes options for pagination, sorting, and selecting specific fields.

.PARAMETER siteId
The site ID to retrieve.

.PARAMETER custId
The customer ID to filter sites by.

.PARAMETER PageNumber
The page number to retrieve in a paginated response.

.PARAMETER PageSize
The number of items per page in a paginated response.

.PARAMETER SortBy
The field by which to sort the results.

.PARAMETER SortOrder
The order to sort the results, either 'asc' for ascending or 'desc' for descending. The default value is 'asc'.

.PARAMETER Select
Specifies the fields to include in the response.

.EXAMPLE
PS C:\> Get-NCSites -custId 123 -Verbose
Retrieves the sites associated with the customer ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCSites -siteId 456
Retrieves the site with the site ID 456.

.EXAMPLE
PS C:\> Get-NCSites -PageNumber 1 -PageSize 10 -SortBy "siteName" -SortOrder "desc"
Retrieves the first page of sites with 10 items per page, sorted by site name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns site data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCSites {
    [CmdletBinding()]
    param (
        [int]$siteId,

        [int]$custId,

        [int]$PageNumber,

        [int]$PageSize,

        [string]$SortBy,

        [string]$SortOrder = "asc",

        [string]$Select
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCSites."
    if ($PSBoundParameters.ContainsKey('custId')) {
        Write-Verbose "[FUNCTION] Retrieving sites for customer ID $custId."
        $endpoint = "api/customers/$custId/sites"
    }
    if ($PSBoundParameters.ContainsKey('siteId')) {
        Write-Verbose "[FUNCTION] Retrieving site with ID $siteId."
        $endpoint = "api/sites/$siteId"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving all sites."
        $endpoint = "api/sites"
    }

    $queryParameters = @{}
    if ($PSBoundParameters.ContainsKey('PageNumber')) { $queryParameters["pageNumber"] = $PageNumber }
    if ($PSBoundParameters.ContainsKey('PageSize')) { $queryParameters["pageSize"] = $PageSize }
    if ($PSBoundParameters.ContainsKey('Select')) { $queryParameters["select"] = $Select }
    if ($PSBoundParameters.ContainsKey('SortBy')) { $queryParameters["sortBy"] = $SortBy }
    if ($PSBoundParameters.ContainsKey('SortOrder')) { $queryParameters["sortOrder"] = $SortOrder }
        
    $queryString = if ($queryParameters.Count) {
        Write-Verbose "[FUNCTION] Query parameters: $($queryParameters | Out-String)"
        $paramsArray = $queryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
        "?" + ($paramsArray -join "&")
    }
    else {
        ""
    }

    $endpoint = "$endpoint$queryString"

    try {
        Write-Verbose "[FUNCTION] Retrieving sites from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving Site data: $_"
    }
}