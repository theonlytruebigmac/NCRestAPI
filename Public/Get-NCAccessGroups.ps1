<#
.SYNOPSIS
Retrieves access groups data from the N-central API.

.DESCRIPTION
The `Get-NCAccessGroups` function retrieves access groups data from the N-central API. 
It supports filtering by organization unit ID or access group ID and includes options for pagination, sorting, and selecting specific fields.

.PARAMETER orgUnitId
The organization unit ID to filter access groups by.

.PARAMETER AccessGroupId
The access group ID to filter access groups by.

.PARAMETER FilterId
The filter ID to apply to the access groups query.

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
PS C:\> Get-NCAccessGroups -orgUnitId 123 -Verbose
Retrieves access groups associated with the organization unit ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCAccessGroups -AccessGroupId 456
Retrieves the access group with the access group ID 456.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns access groups data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCAccessGroups {
    [CmdletBinding()]
    param (
        [int]$orgUnitId,

        [int]$AccessGroupId,

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

    Write-Verbose "[FUNCTION] Running Get-NCAccessGroups."
    $providedParams = @($OrgUnitId, $AccessGroupId) | Where-Object { $_ }
    if ($providedParams.Count -ne 1) {
        Write-Error "You must provide exactly one of the following parameters: OrgUnitId or AccessGroupId."
        return
    }

    if (-not $AccessGroupId) {
        Write-Verbose "[FUNCTION] AccessGroupId is not provided. Retrieving access groups for orgUnitId: $orgUnitId."
        $endpoint = "api/org-units/$orgUnitId/access-groups"
    }
    else {
        Write-Verbose "[FUNCTION] AccessGroupId is provided. Retrieving access groups for AccessGroupID $AccessGroupId."
        $endpoint = "api/access-groups/$AccessGroupId"
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
        Write-Verbose "[FUNCTION] Retrieving access groups data from $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving access groups: $_"
    }
}