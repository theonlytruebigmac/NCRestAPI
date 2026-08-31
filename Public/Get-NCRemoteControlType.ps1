<#
.SYNOPSIS
Retrieves the remote-control configuration for a device.

.DESCRIPTION
GET /api/devices/{deviceId}/remote-control-type.

.PARAMETER DeviceId
Target device.

.EXAMPLE
Get-NCRemoteControlType -DeviceId 987
#>
function Get-NCRemoteControlType {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$DeviceId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCRemoteControlType: api/devices/$DeviceId/remote-control-type"
        $api.Get("api/devices/$DeviceId/remote-control-type")
    }
}
