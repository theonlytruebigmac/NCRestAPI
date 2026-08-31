<#
.SYNOPSIS
Retrieves the status of a given task using the task ID or retrieves detailed statuses per device.

.DESCRIPTION
The `Get-NCScheduledTaskStatus` function retrieves the status of the given task from the N-central API based on the provided task ID. If the `-details` switch is specified, it retrieves detailed statuses for each device associated with the task instead.

.PARAMETER TaskId
Specifies the ID of the task for which status needs to be fetched.

.PARAMETER Details
If specified, retrieves detailed statuses per device for the given task.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -TaskId "12345"
Retrieves the aggregated status for the task with ID 12345.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -TaskId "12345" -Details
Retrieves the detailed status for the task with ID 12345.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -TaskId "12345" -Verbose
Retrieves the aggregated status for the task with ID 12345 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCScheduledTaskStatus -TaskId "12345" -Details -Verbose
Retrieves the detailed status for the task with ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the status of the specified task or the detailed statuses per device if `-details` is specified.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function Get-NCScheduledTaskStatus {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskId,

        [switch]$Details
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        $endpoint = if ($Details) {
            "api/scheduled-tasks/$TaskId/status/details"
        } else {
            "api/scheduled-tasks/$TaskId/status"
        }
        Write-Verbose "[FUNCTION] Get-NCScheduledTaskStatus: $endpoint"
        $api.Get($endpoint)
    }
}