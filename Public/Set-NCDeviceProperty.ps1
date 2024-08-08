<#
.SYNOPSIS
Sets a custom property for a device in the N-central API.

.DESCRIPTION
The `Set-NCDeviceProperty` function sets a custom property for a device in the N-central API.
It requires parameters to specify the device ID, property ID, and value.

.PARAMETER DeviceId
The device ID for which the property will be set. This parameter is mandatory.

.PARAMETER PropertyId
The ID of the property to be set. This parameter is mandatory.

.PARAMETER Value
The value to be set for the property. This parameter is mandatory.

.EXAMPLE
PS C:\> Set-NCDeviceProperty -DeviceId 12345 -PropertyId 678 -Value "New Value" -Verbose
Sets a custom property for the device with the ID 12345 and property ID 678 with the value "New Value", with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after setting the device property.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Set-NCDeviceProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$DeviceId,

        [Parameter(Mandatory = $true)]
        [int]$PropertyId,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance

    Write-Verbose "[FUNCTION] Running Set-NCDeviceProperty."
    $body = @{
        value = $Value
    }

    $endpoint = "api/devices/$deviceId/custom-properties/$propertyId"

    $bodyJson = $body | ConvertTo-Json -Depth 10

    try {
        Write-Verbose "[FUNCTION] Setting device property with endpoint: $endpoint."
        $response = $api.Put($endpoint, $bodyJson)
        return $response
    }
    catch {
        Write-Error "Error setting organization property: $_"
    }
}