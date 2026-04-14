<#
.SYNOPSIS
Retrieves job statuses for an organization unit from the N-central API.

.DESCRIPTION
The `Get-NCJobStatus` function retrieves job statuses for an organization unit from the N-central API.
It requires an organization unit ID to specify the unit whose job statuses are to be retrieved.

.PARAMETER OrgUnitId
The organization unit ID for which to retrieve job statuses. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCJobStatus -OrgUnitId 12345 -Verbose
Retrieves the job statuses for the organization unit with the ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns job status data for an organization unit from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function Get-NCJobStatus {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId
    )

    begin { $api = Get-NCRestApiInstance }



    process {
    Write-Verbose "[FUNCTION] Get-NCJobStatus: invoked."
    $endpoint = "api/org-units/$orgUnitId/job-statuses"

        Write-Verbose "[FUNCTION] Retrieving job status with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data


    }
}
