<#
.SYNOPSIS
Retrieves service monitor status for a device from the N-central API.

.DESCRIPTION
The `Get-NCDeviceServices` function retrieves the service monitor status for a device from the N-central API.
It requires a device ID to specify the device whose service monitor status is to be retrieved.

.PARAMETER DeviceId
The device ID for which to retrieve service monitor status. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCDeviceServices -DeviceId 12345 -Verbose
Retrieves the service monitor status for the device with the ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the service monitor status for a device from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function Get-NCDeviceServices {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Get-NCDeviceServices: api/devices/$DeviceId/service-monitor-status"
        $api.Get("api/devices/$DeviceId/service-monitor-status")
    }
}
