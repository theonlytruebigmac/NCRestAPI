<#
.SYNOPSIS
Retrieves custom properties of a device from the N-central API.

.DESCRIPTION
The `Get-NCDeviceProperty` function retrieves custom properties of a device from the N-central API.
It requires a device ID and supports optional parameters for filtering, pagination, sorting, and selecting specific fields.

.PARAMETER deviceId
The device ID to filter custom properties by. This parameter is mandatory.

.PARAMETER FilterId
The filter ID to apply to the custom properties query.

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
PS C:\> Get-NCDeviceProperty -deviceId 12345 -Verbose
Retrieves custom properties for the device with the ID 12345 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCDeviceProperty -deviceId 12345 -PageNumber 1 -PageSize 10 -SortBy "propertyName" -SortOrder "desc"
Retrieves the first page of custom properties for the device with 10 items per page, sorted by property name in descending order.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns custom properties data for a device from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCDeviceProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$deviceId,

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
    
    Write-Verbose "[FUNCTION] Running Get-NCDeviceProperty."
    $endpoint = "api/devices/$deviceId/custom-properties"
 
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
        Write-Verbose "[FUNCTION] Retrieving device custom properties with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving device custom properties: $_"
    }
}