<#
.SYNOPSIS
Retrieves scheduled tasks for a device from the N-central API.

.DESCRIPTION
The `Get-NCScheduledTasks` function retrieves scheduled tasks from the N-central API.
It requires a task ID to specify the scheduled tasks to be retrieved.

.PARAMETER TaskId
The Task ID for which to retrieve scheduled tasks. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCScheduledTasks -TaskId 12345 -Verbose
Retrieves the scheduled tasks with the ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns scheduled task data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCScheduledTasks {
    [CmdletBinding()]
    param (
        [int]$taskid
    )
    
    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCScheduledTasks."

    if (-not $taskid) {
        Write-Verbose "[FUNCTION] Getting all scheduled tasks."
        $endpoint = "api/scheduled-tasks/"
    }
    else {
        Write-Verbose "[FUNCTION] Getting scheduled tasks for task ID: $taskid."
        $endpoint = "api/scheduled-tasks/$taskid"
    }

    try {
        Write-Verbose "[FUNCTION] Retriving device tasks for endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving device tasks $_"
    }
}