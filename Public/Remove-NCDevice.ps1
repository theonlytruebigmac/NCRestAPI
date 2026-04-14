<#
.SYNOPSIS
Deletes a device from N-central.

.DESCRIPTION
Calls DELETE /api/devices/{deviceId}. Requires confirmation unless `-Force` is used or
`$ConfirmPreference` is lowered. When `-RemoveAgents` is supplied the server is asked to
also uninstall the agent from the endpoint.

.PARAMETER DeviceId
Device to delete. Accepts pipeline input by property name.

.PARAMETER RemoveAgents
If supplied, N-central removes the agent as part of the delete.

.PARAMETER Force
Skip the confirmation prompt.

.EXAMPLE
Remove-NCDevice -DeviceId 987654321 -Confirm

.EXAMPLE
Get-NCDevices -All | Where-Object status -eq 'Decommissioned' | Remove-NCDevice -Force
#>
function Remove-NCDevice {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [switch]$RemoveAgents,

        [switch]$Force
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $query = @{}
        if ($RemoveAgents) { $query['removeAgents'] = 'true' }
        $endpoint = "api/devices/$DeviceId$(ConvertTo-NCQueryString -Parameters $query)"

        if ($Force -or $PSCmdlet.ShouldProcess($DeviceId, 'Delete N-central device')) {
            Write-Verbose "[FUNCTION] Remove-NCDevice: DELETE $endpoint"
            $api.Delete($endpoint)
        }
    }
}
