<#
.SYNOPSIS
Retrieves notes for a device.

.DESCRIPTION
GET /api/devices/{deviceId}/notes. Supports pagination and pipeline input.

.PARAMETER DeviceId
Target device.

.EXAMPLE
Get-NCDeviceNotes -DeviceId 987 -All
#>
function Get-NCDeviceNotes {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        $endpoint = "api/devices/$DeviceId/notes"

        if ($All) {
            return Invoke-NCPagedRequest -Endpoint $endpoint
        }

        $queryParameters = @{}
        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }
        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCDeviceNotes: $endpoint"
        $api.Get($endpoint)
    }
}
