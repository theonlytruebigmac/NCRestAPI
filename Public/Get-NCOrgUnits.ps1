<#
.SYNOPSIS
Retrieves organization units from the N-central API.

.DESCRIPTION
The `Get-NCOrgUnits` function retrieves organization units from the N-central API.
It supports retrieving specific organization units by ID, including their children. 
Optional parameters allow for pagination, sorting, and selecting specific fields.

.PARAMETER OrgUnitId
The organization unit ID to retrieve.

.PARAMETER PageNumber
The page number to retrieve in a paginated response. The default value is 1.

.PARAMETER PageSize
The number of items per page in a paginated response. The default value is 50.

.PARAMETER SortBy
The field by which to sort the results.

.PARAMETER SortOrder
The order to sort the results, either 'asc' for ascending or 'desc' for descending. The default value is 'asc'.

.PARAMETER Children
Include this switch to retrieve the children of the specified organization unit ID.

.EXAMPLE
PS C:\> Get-NCOrgUnits -OrgUnitId 123 -Verbose
Retrieves the organization unit with the ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCOrgUnits -OrgUnitId 123 -Children -Verbose
Retrieves the children of the organization unit with the ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCOrgUnits -PageNumber 1 -PageSize 10 -SortBy "unitName" -SortOrder "desc"
Retrieves the first page of organization units with 10 items per page, sorted by unit name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns organization unit data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCOrgUnits {
    [CmdletBinding()]
    param (
        [int]$OrgUnitId,

        [int]$PageNumber = 1,

        [int]$PageSize = 50,

        [string]$SortBy,

        [string]$SortOrder = "asc",

        [switch]$Children
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance

    Write-Verbose "[FUNCTION] Running Get-NCOrgUnits."
    if ($PSBoundParameters.ContainsKey('OrgUnitId') -and $Children.IsPresent) {
        Write-Verbose "[FUNCTION] Retrieving children of organization unit ID $OrgUnitId."
        $endpoint = "api/org-units/$OrgUnitId/children"
    }
    elseif ($PSBoundParameters.ContainsKey('OrgUnitId')) {
        Write-Verbose "[FUNCTION] Retrieving organization unit with ID $OrgUnitId."
        $endpoint = "api/org-units/$OrgUnitId"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving all organization units."
        $endpoint = "api/org-units"
    }

    $queryParameters = @{}
    if ($PSBoundParameters.ContainsKey('PageNumber')) { $queryParameters["pageNumber"] = $PageNumber }
    if ($PSBoundParameters.ContainsKey('PageSize')) { $queryParameters["pageSize"] = $PageSize }
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
        Write-Verbose "[FUNCTION] Retrieving organization units from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving Organization Units: $_"
    }
}