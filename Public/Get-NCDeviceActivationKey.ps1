<#
.SYNOPSIS
Retrieves the activation key for a device.

.DESCRIPTION
Calls GET /api/devices/{deviceId}/activation-key. Accepts pipeline input by property name.

.PARAMETER DeviceId
Device whose activation key should be returned.

.EXAMPLE
Get-NCDeviceActivationKey -DeviceId 987654321

.EXAMPLE
Get-NCDevices -OrgUnitId 1 -All | Get-NCDeviceActivationKey
#>
function Get-NCDeviceActivationKey {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCDeviceActivationKey: api/devices/$DeviceId/activation-key"
        $api.Get("api/devices/$DeviceId/activation-key")
    }
}
