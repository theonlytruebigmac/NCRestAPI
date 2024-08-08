<#
.SYNOPSIS
Retrieves user roles from the N-central API.

.DESCRIPTION
The `Get-NCUserRoles` function retrieves user roles from the N-central API.
It supports retrieving user roles by customer ID or user role ID and includes options for filtering, pagination, sorting, and selecting specific fields.

.PARAMETER CustID
The customer ID to filter user roles by.

.PARAMETER UserRoleId
The user role ID to retrieve specific user role details.

.PARAMETER FilterId
The filter ID to apply to the user roles query.

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
PS C:\> Get-NCUserRoles -CustID 123 -EnableVerbose
Retrieves user roles associated with the customer ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCUserRoles -UserRoleId 456
Retrieves the user role with the user role ID 456.

.EXAMPLE
PS C:\> Get-NCUserRoles -CustID 123 -PageNumber 1 -PageSize 10 -SortBy "roleName" -SortOrder "desc"
Retrieves the first page of user roles with 10 items per page, sorted by role name in descending order for the customer ID 123.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns user role data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCUserRoles {
    [CmdletBinding()]
    param (
        [int]$CustID,

        [int]$UserRoleId,

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
    
    Write-Verbose "[FUNCTION] Running Get-NCUserRoles."
    $providedParams = @($CustId, $UserRoleId) | Where-Object { $_ }
    if ($providedParams.Count -ne 1) {
        Write-Error "You must provide exactly one of the following parameters: CustId or UserRoleId."
        return
    }

    if (-not $UserRoleId) {
        Write-Verbose "[FUNCTION] Retrieving user roles for customer ID $CustID."
        $endpoint = "api/org-units/$CustID/user-roles"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving user role with ID $UserRoleId."
        $endpoint = "api/org-units/$CustID/user-roles/$UserRoleId"
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
        Write-Verbose "[FUNCTION] Retrieving user roles from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving user roles: $_"
    }
}
