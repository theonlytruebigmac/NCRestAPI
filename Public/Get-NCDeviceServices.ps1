<#
.SYNOPSIS
Retrieves service monitor status for a device from the N-central API.

.DESCRIPTION
The `Get-NCDeviceServices` function retrieves the service monitor status for a device from the N-central API.
It requires a device ID to specify the device whose service monitor status is to be retrieved.

.PARAMETER deviceId
The device ID for which to retrieve service monitor status. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCDeviceServices -deviceId 12345 -Verbose
Retrieves the service monitor status for the device with the ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the service monitor status for a device from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCDeviceServices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$deviceId
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCDeviceServices."
    $endpoint = "api/devices/$DeviceId/service-monitor-status"

    try {
        Write-Verbose "[FUNCTION] Retriving device services for endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving device services $_"
    }

}