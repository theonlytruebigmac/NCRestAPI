<#
.SYNOPSIS
Retrieves users from the N-central API.

.DESCRIPTION
The `Get-NCUsers` function retrieves users from the N-central API.
It supports retrieving users by customer ID and includes options for filtering, pagination, sorting, and selecting specific fields.

.PARAMETER CustId
The customer ID to filter users by.

.PARAMETER FilterId
The filter ID to apply to the users query.

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

.PARAMETER EnableVerbose
Enables verbose output.

.EXAMPLE
PS C:\> Get-NCUsers -CustId 123 -EnableVerbose
Retrieves users associated with the customer ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCUsers -PageNumber 1 -PageSize 10 -SortBy "userName" -SortOrder "desc"
Retrieves the first page of users with 10 items per page, sorted by user name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns user data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCUsers {
    param (
        [int]$CustId,

        [int]$FilterId,

        [int]$PageNumber,

        [int]$PageSize,

        [string]$Select,

        [string]$SortBy,

        [string]$SortOrder = "asc"
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance

    Write-Verbose "[FUNCTION] Running Get-NCUsers."
    if (-not $CustId) {
        Write-Verbose "[FUNCTION] No customer ID provided. Retrieving all users."
        $endpoint = "api/users"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving users for customer ID $CustId."
        $endpoint = "api/org-units/$CustID/users"
    }

    $queryParameters = @{}
    if ($PSBoundParameters.ContainsKey('FilterId')) { $queryParameters["filterId"] = $FilterId }
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
        Write-Verbose "[FUNCTION] Retrieving users with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving user roles: $_"
    }
}
