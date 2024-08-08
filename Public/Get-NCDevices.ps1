<#
.SYNOPSIS
Retrieves devices from the N-central API.

.DESCRIPTION
The `Get-NCDevices` function retrieves devices from the N-central API.
It supports retrieving devices by customer ID or device ID. 
Optional parameters allow for filtering, pagination, sorting, and selecting specific fields.

.PARAMETER CustID
The customer ID to filter devices by.

.PARAMETER FilterId
The filter ID to apply to the devices query.

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

.PARAMETER DeviceID
The device ID to retrieve specific device details.

.EXAMPLE
PS C:\> Get-NCDevices -CustID 123 -Verbose
Retrieves devices associated with the customer ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCDevices -DeviceID 456
Retrieves the device with the device ID 456.

.EXAMPLE
PS C:\> Get-NCDevices -CustID 123 -PageNumber 1 -PageSize 10 -SortBy "deviceName" -SortOrder "desc"
Retrieves the first page of devices with 10 items per page, sorted by device name in descending order for the customer ID 123.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns device data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCDevices {
    [CmdletBinding()]
    param (
        [int]$orgUnitId,

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

    Write-Verbose "[FUNCTION] Running Get-NCDevices."

    function Get-Endpoint {
        param (
            [int]$orgUnitId,
            [int]$deviceId,
            [hashtable]$QueryParameters
        )

        if ($deviceId) {
            Write-Verbose "[FUNCTION] Retrieving device with deviceID: $deviceId."
            $endpoint = "api/devices/$deviceId"
        }
        elseif ($orgUnitID) {
            Write-Verbose "[FUNCTION] Retrieving devices for orgUnitId: $orgUnitId."
            $endpoint = "api/org-units/$orgUnitId/devices"
        }
        else {
            Write-Verbose "[FUNCTION] Retrieving all devices."
            $endpoint = "api/devices"
        }

        if ($QueryParameters.Count) {
            $paramsArray = $QueryParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
            $queryString = "?" + ($paramsArray -join "&")
            return "$endpoint$queryString"
        }
        else {
            return $endpoint
        }
    }

    function Get-QueryParameters {
        param (
            [Parameter(Mandatory = $false)][int]$FilterId,
            [Parameter(Mandatory = $false)][int]$PageNumber,
            [Parameter(Mandatory = $false)][int]$PageSize,
            [Parameter(Mandatory = $false)][string]$Select,
            [Parameter(Mandatory = $false)][string]$SortBy,
            [Parameter(Mandatory = $false)][string]$SortOrder
        )

        $queryParameters = @{}
        if ($PSBoundParameters.ContainsKey('FilterId') -and $FilterId) { $queryParameters["filterId"] = $FilterId }
        if ($PSBoundParameters.ContainsKey('PageNumber') -and $PageNumber) { $queryParameters["pageNumber"] = $PageNumber }
        if ($PSBoundParameters.ContainsKey('PageSize') -and $PageSize) { $queryParameters["pageSize"] = $PageSize }
        if ($PSBoundParameters.ContainsKey('Select') -and $Select) { $queryParameters["select"] = $Select }
        if ($PSBoundParameters.ContainsKey('SortBy') -and $SortBy) { $queryParameters["sortBy"] = $SortBy }
        if ($PSBoundParameters.ContainsKey('SortOrder') -and $SortOrder -and $SortOrder -ne "asc") { $queryParameters["sortOrder"] = $SortOrder }

        Write-Verbose "[FUNCTION] Query parameters: $($queryParameters | Out-String)"
        return $queryParameters
    }

    try {
        if (-not $orgUnitId -and -not $deviceId) {
            Write-Verbose "[FUNCTION] No orgUnitiD or DeviceID provided, retrieving list of devices for orgUnitId 1."

            try {
                $devices = $api.Get("api/org-units/1/devices")
                return $devices
            }
            catch {
                Write-Error "Error retrieving devices from System Level: $_"
            }
        }
        else {
            Write-Verbose "[FUNCTION] Retrieving list of devices from orgUnitId $orgUnitId."
        }

        $queryParameters = Get-QueryParameters -FilterId $FilterId -PageNumber $PageNumber -PageSize $PageSize -Select $Select -SortBy $SortBy -SortOrder $SortOrder
        $endpoint = Get-Endpoint -orgUnitId $orgUnitId -DeviceID $deviceId -QueryParameters $queryParameters

        Write-Verbose "[FUNCTION] Retrieving devices from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving devices: $_"
    }
}