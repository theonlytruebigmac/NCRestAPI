<#
.SYNOPSIS
Modifies existing maintenance windows by schedule ID.

.DESCRIPTION
Calls PUT /api/devices/maintenance-windows.

.PARAMETER MaintenanceWindows
Array of maintenance-window update objects. Each must include the `scheduleId` it is
modifying along with the fields to update.

.EXAMPLE
Set-NCMaintenanceWindows -MaintenanceWindows @(@{ scheduleId='abc'; durationMinutes=120 })
#>
function Set-NCMaintenanceWindows {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [object[]]$MaintenanceWindows
    )
    $api = Get-NCRestApiInstance
    $body = @{ maintenanceWindows = $MaintenanceWindows }
    $ids = ($MaintenanceWindows | ForEach-Object { $_.scheduleId }) -join ','
    if (-not $PSCmdlet.ShouldProcess($ids, 'Update maintenance windows')) { return }
    $api.Put('api/devices/maintenance-windows', $body)
}
