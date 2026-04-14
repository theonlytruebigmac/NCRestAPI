<#
.SYNOPSIS
Retrieves maintenance windows for a device.

.DESCRIPTION
Calls GET /api/devices/{deviceId}/maintenance-windows. Accepts pipeline input by property name.

.EXAMPLE
Get-NCDeviceMaintenanceWindows -DeviceId 987654321
#>
function Get-NCDeviceMaintenanceWindows {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCDeviceMaintenanceWindows: api/devices/$DeviceId/maintenance-windows"
        $api.Get("api/devices/$DeviceId/maintenance-windows")
    }
}
