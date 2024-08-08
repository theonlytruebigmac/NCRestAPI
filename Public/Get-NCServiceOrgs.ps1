<#
.SYNOPSIS
Retrieves service organizations from the N-central API.

.DESCRIPTION
The `Get-NCServiceOrgs` function retrieves service organizations from the N-central API.
It supports retrieving service organizations by ID and includes options for pagination and sorting.

.PARAMETER soId
The service organization ID to filter by.

.PARAMETER PageNumber
The page number to retrieve in a paginated response. The default value is 1.

.PARAMETER PageSize
The number of items per page in a paginated response. The default value is 50.

.PARAMETER SortBy
The field by which to sort the results.

.PARAMETER SortOrder
The order to sort the results, either 'asc' for ascending or 'desc' for descending. The default value is 'asc'.

.EXAMPLE
PS C:\> Get-NCServiceOrgs -soId 123 -Verbose
Retrieves the service organization with the ID 123 and its customers with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCServiceOrgs -PageNumber 1 -PageSize 10 -SortBy "orgName" -SortOrder "desc"
Retrieves the first page of service organizations with 10 items per page, sorted by organization name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns service organization data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCServiceOrgs {
    [CmdletBinding()]
    param (
        [int]$soId,

        [int]$PageNumber = 1,

        [int]$PageSize = 50,

        [string]$SortBy,

        [string]$SortOrder = "asc"
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
        
    Write-Verbose "[FUNCTION] Running Get-NCServiceOrgs."
    if ($PSBoundParameters.ContainsKey('SOID')) {
        Write-Verbose "[FUNCTION] Retrieving service organization with ID $soId."
        $endpoint = "api/service-orgs/$soId/customers"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving all service organizations."
        $endpoint = "api/service-orgs"
    }

    $queryParameters = @{}
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
        Write-Verbose "[FUNCTION] Retrieving service organizations with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving access groups: $_"
    }
}
