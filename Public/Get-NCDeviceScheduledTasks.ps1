<#
.SYNOPSIS
Retrieves scheduled tasks assigned to a device.

.DESCRIPTION
GET /api/devices/{deviceId}/scheduled-tasks. Accepts pipeline input on DeviceId.

.EXAMPLE
Get-NCDeviceScheduledTasks -DeviceId 987

.EXAMPLE
Get-NCDevices -OrgUnitId 1 -All | Get-NCDeviceScheduledTasks
#>
function Get-NCDeviceScheduledTasks {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCDeviceScheduledTasks: invoked."
        $api.Get("api/devices/$DeviceId/scheduled-tasks")
    }
}
