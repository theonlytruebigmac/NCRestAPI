<#
.SYNOPSIS
Retrieves the status of a given task using the task ID or retrieves detailed statuses per device.

.DESCRIPTION
The `Get-NCScheduledTaskStatus` function retrieves the status of the given task from the N-central API based on the provided task ID. If the `-details` switch is specified, it retrieves detailed statuses for each device associated with the task instead.

.PARAMETER taskId
Specifies the ID of the task for which status needs to be fetched.

.PARAMETER details
If specified, retrieves detailed statuses per device for the given task.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -taskId "12345"
Retrieves the aggregated status for the task with ID 12345.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -taskId "12345" -details
Retrieves the detailed status for the task with ID 12345.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -taskId "12345" -Verbose
Retrieves the aggregated status for the task with ID 12345 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -taskId "12345" -details -Verbose
Retrieves the detailed status for the task with ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the status of the specified task or the detailed statuses per device if `-details` is specified.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCScheduledTaskStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$taskId,

        [switch]$details
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    Write-Verbose "[FUNCTION] Running Get-NCScheduledTaskStatus."
    
    if ($details) {
        Write-Verbose "[FUNCTION] Retrieving detailed status for task ID: $taskId."
        $endpoint = "api/scheduled-tasks/$taskId/status/details"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving status for task ID: $taskId."
        $endpoint = "api/scheduled-tasks/$taskId/status"
    }

    try {
        Write-Verbose "[FUNCTION] Retrieving task status for endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving task status: $_"
    }
}