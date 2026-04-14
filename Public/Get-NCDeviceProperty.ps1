<#
.SYNOPSIS
Retrieves custom properties for a device.

.DESCRIPTION
Returns all custom properties on a device, or a single property by ID. Supports `-All`
auto-pagination and pipeline input.

.EXAMPLE
Get-NCDeviceProperty -DeviceId 987 -All

.EXAMPLE
Get-NCDevices -All | Get-NCDeviceProperty -All
#>
function Get-NCDeviceProperty {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PropertyId,

        [int]$FilterId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$Select,
        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        if ($PropertyId) {
            return $api.Get("api/devices/$DeviceId/custom-properties/$PropertyId")
        }

        $endpoint = "api/devices/$DeviceId/custom-properties"

        $queryParameters = @{}
        Add-NCCommonQuery -Parameters $queryParameters -FilterId $FilterId -Select $Select -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCDeviceProperty: $endpoint"
        $api.Get($endpoint)
    }
}
