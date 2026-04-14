<#
.SYNOPSIS
Retrieves the appliance-task information for a given task ID from the N-central API.

.DESCRIPTION
The `Get-NCApplianceTask` function retrieves the appliance-task information for a specified task ID from the N-central API.

.PARAMETER taskId
Specifies the task ID for which to fetch the appliance-task information. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCApplianceTask -taskId "abc123" -Verbose
Retrieves the appliance-task information for the task with ID "abc123" and enables verbose output.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the appliance-task information from the specified N-central API endpoint.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCApplianceTask {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$taskId
    )

    begin { $api = Get-NCRestApiInstance }



    process {
    Write-Verbose "[FUNCTION] Running Get-NCApplianceTask."
    $endpoint = "api/appliance-tasks/$taskId"

        Write-Verbose "[FUNCTION] Retrieving appliance task data from endpoint $endpoint."
        $data = $api.Get($endpoint)
        return $data


    }
}
