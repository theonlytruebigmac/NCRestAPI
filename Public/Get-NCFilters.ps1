<#
.SYNOPSIS
Retrieves device filters from the N-central API.

.DESCRIPTION
The `Get-NCFilters` function retrieves device filters from the N-central API.
Optional parameters allow for specifying the view scope, pagination, sorting, and selecting specific fields.

.PARAMETER viewScope
The scope of the view to filter the devices by. The default value is "ALL".

.PARAMETER PageNumber
The page number to retrieve in a paginated response.

.PARAMETER PageSize
The number of items per page in a paginated response.

.PARAMETER Select
Specifies the fields to include in the response.

.PARAMETER SortBy
The field by which to sort the results.

.PARAMETER SortOrder
The order to sort the results, either 'asc' for ascending or 'desc' for descending. The default value is 'asc'.

.EXAMPLE
PS C:\> Get-NCFilters -viewScope "ALL" -Verbose
Retrieves device filters with the view scope set to "ALL" and verbose output enabled.

.EXAMPLE
PS C:\> Get-NCFilters -viewScope "CUSTOM" -PageNumber 1 -PageSize 10 -SortBy "filterName" -SortOrder "desc"
Retrieves the first page of custom device filters with 10 items per page, sorted by filter name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns device filter data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCFilters {
    [CmdletBinding()]
    param (
        [ValidateSet("ALL", "OWN_AND_USED")]
        [string]$viewScope = "ALL",

        [int]$pageNumber,

        [int]$pageSize,

        [string]$select,

        [string]$sortBy,

        [string]$sortOrder = "asc"
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCFilters."
    $endpoint = "api/device-filters"

    $queryParameters = @{}
    if ($PSBoundParameters.ContainsKey('viewScope')) { $queryParameters["viewScope"] = $viewScope }
    if ($PSBoundParameters.ContainsKey('PageNumber')) { $queryParameters["pageNumber"] = $PageNumber }
    if ($PSBoundParameters.ContainsKey('PageSize')) { $queryParameters["pageSize"] = $PageSize }
    if ($PSBoundParameters.ContainsKey('Select')) { $queryParameters["select"] = $Select }
    if ($PSBoundParameters.ContainsKey('SortBy')) { $queryParameters["sortBy"] = $SortBy }
    if ($PSBoundParameters.ContainsKey('SortOrder')) { $queryParameters["sortOrder"] = $SortOrder }
    
    $queryString = if ($queryParameters.Count) {
        Write-Verbose "[FUNCTION] Query parameters: $queryParameters"
        $paramsArray = $queryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
        "?" + ($paramsArray -join "&")
    }
    else {
        ""
    }

    $endpoint = "$endpoint$queryString"

    try {
        Write-Verbose "[FUNCTION] Retrieving filters with from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving filters: $_"
    }
}
