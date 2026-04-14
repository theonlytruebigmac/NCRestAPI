<#
.SYNOPSIS
Retrieves scheduled tasks from the N-central API.

.DESCRIPTION
Returns all scheduled tasks, or a specific task by ID. Supports `-All` auto-pagination
and pipeline input.

.PARAMETER TaskId
Specific scheduled task to retrieve.

.PARAMETER All
Auto-paginate across all scheduled tasks.

.EXAMPLE
Get-NCScheduledTasks -TaskId abc123

.EXAMPLE
Get-NCScheduledTasks -All
#>
function Get-NCScheduledTasks {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TaskId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {

        Write-Verbose "[FUNCTION] Get-NCScheduledTasks: invoked."
        if ($TaskId) {
            return $api.Get("api/scheduled-tasks/$TaskId")
        }
        # N-central has no bulk "list all scheduled tasks" endpoint. /api/scheduled-tasks
        # is a hypermedia navigation (returns only _links). Callers must fetch tasks per
        # device via Get-NCDeviceScheduledTasks, or look up a known TaskId.
        throw "Get-NCScheduledTasks requires -TaskId. N-central does not expose a bulk-list endpoint; use Get-NCDeviceScheduledTasks -DeviceId X to enumerate a device's tasks, or pipe devices in: Get-NCDevices -All | Get-NCDeviceScheduledTasks."
    }
}
