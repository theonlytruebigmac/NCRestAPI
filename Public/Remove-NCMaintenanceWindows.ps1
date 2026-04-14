<#
.SYNOPSIS
Deletes maintenance windows by schedule ID.

.DESCRIPTION
Calls DELETE /api/devices/maintenance-windows with the schedule IDs to delete in the body.

.PARAMETER ScheduleIds
Array of schedule IDs to remove.

.PARAMETER Force
Skip the confirmation prompt.

.EXAMPLE
Remove-NCMaintenanceWindows -ScheduleIds 'abc','def'
#>
function Remove-NCMaintenanceWindows {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('scheduleId')]
        [object[]]$ScheduleIds,

        [switch]$Force
    )
    begin {
        $api = Get-NCRestApiInstance
        $collected = [System.Collections.Generic.List[object]]::new()
    }
    process {
        Write-Verbose "[FUNCTION] Remove-NCMaintenanceWindows: invoked."
        foreach ($id in $ScheduleIds) { $collected.Add($id) }
    }
    end {
        $target = $collected -join ','
        if ($Force -or $PSCmdlet.ShouldProcess($target, 'Delete maintenance windows')) {
            $body = @{ scheduleIds = $collected.ToArray() }
            $api.Delete('api/devices/maintenance-windows', $body)
        }
    }
}
