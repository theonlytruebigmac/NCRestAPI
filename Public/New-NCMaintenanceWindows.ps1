<#
.SYNOPSIS
Creates maintenance windows for one or more devices.

.DESCRIPTION
Calls POST /api/devices/maintenance-windows.

.PARAMETER DeviceIds
Array of device IDs the windows apply to.

.PARAMETER MaintenanceWindows
Array of maintenance-window objects, shaped per the `MaintenanceWindowsRequest` schema.

.EXAMPLE
New-NCMaintenanceWindows -DeviceIds 111,222 -MaintenanceWindows @(@{ startDateTime='2026-04-15T02:00:00Z'; durationMinutes=60 })
#>
function New-NCMaintenanceWindows {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [object[]]$DeviceIds,

        [Parameter(Mandatory)]
        [object[]]$MaintenanceWindows
    )
    $api = Get-NCRestApiInstance
    $body = @{
        deviceIDs          = $DeviceIds
        maintenanceWindows = $MaintenanceWindows
    }
    if (-not $PSCmdlet.ShouldProcess(($DeviceIds -join ','), 'Create maintenance windows')) { return }
    $api.Post('api/devices/maintenance-windows', $body)
}
