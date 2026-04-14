<#
.SYNOPSIS
Retrieves asset-lifecycle information for a device.

.DESCRIPTION
GET /api/devices/{deviceId}/assets/lifecycle-info.

.EXAMPLE
Get-NCAssetLifecycle -DeviceId 987
#>
function Get-NCAssetLifecycle {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $api.Get("api/devices/$DeviceId/assets/lifecycle-info")
    }
}
