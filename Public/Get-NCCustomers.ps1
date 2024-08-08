<#
.SYNOPSIS
Retrieves customer data from the N-central API.

.DESCRIPTION
The `Get-NCCustomers` function retrieves customer data from the N-central API. 
It supports retrieving customers by service organization ID (soId) or customer ID (custId). 
Optional parameters allow for pagination, sorting, and selecting specific fields.

.PARAMETER soId
The service organization ID to filter customers by.

.PARAMETER custId
The customer ID to filter customers by.

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
PS C:\> Get-NCCustomers -soId 123 -Verbose
Retrieves customers associated with the service organization ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCCustomers -custId 456
Retrieves the customer with the customer ID 456.

.EXAMPLE
PS C:\> Get-NCCustomers -PageNumber 1 -PageSize 10 -SortBy "customerName" -SortOrder "desc"
Retrieves the first page of customers with 10 items per page, sorted by customer name in descending order.

.EXAMPLE
PS C:\> Get-NCCustomers -Select "customerName,city,stateProv"
Retrieves customers with only the specified fields: customer name, city, and state province.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns customer data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCCustomers {
    [CmdletBinding()]
    param (
        [int]$soId,

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
    
    Write-Verbose "[FUNCTION] Running Get-NCCustomers."

    if ($PSBoundParameters.ContainsKey('soId')) {
        Write-Verbose "[FUNCTION] Retrieving customers for soID: $soId."
        $endpoint = "api/service-orgs/$soId/customers"
    }
    elseif ($PSBoundParameters.ContainsKey('custId')) {
        Write-Verbose "[FUNCTION] Retrieving customer with custID: $custId."
        $endpoint = "api/customers/$custId"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving all customers."
        $endpoint = "api/customers"
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
        Write-Verbose "[FUNCTION] Getting customer data from endpoint $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving Customer data: $_"
    }
}