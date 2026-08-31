<#
.SYNOPSIS
Retrieves a scheduled task by ID from the N-central API.

.DESCRIPTION
N-central does not expose a bulk "list all scheduled tasks" endpoint.
Use Get-NCDeviceScheduledTasks to enumerate tasks per device.

.PARAMETER TaskId
Specific scheduled task to retrieve.

.EXAMPLE
Get-NCScheduledTasks -TaskId abc123
#>
function Get-NCScheduledTasks {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskId
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Get-NCScheduledTasks: api/scheduled-tasks/$TaskId"
        $api.Get("api/scheduled-tasks/$TaskId")
    }
}
