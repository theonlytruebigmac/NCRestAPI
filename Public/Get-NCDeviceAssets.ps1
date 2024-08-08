<#
.SYNOPSIS
Retrieves device assets from the N-central API.

.DESCRIPTION
The `Get-NCDeviceAssets` function retrieves device assets from the N-central API.
It requires a device ID to specify the device whose assets are to be retrieved.

.PARAMETER DeviceId
The device ID for which to retrieve assets. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCDeviceAssets -DeviceId 12345 -Verbose
Retrieves the assets for the device with the ID 12345 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns device assets data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCDeviceAssets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$DeviceId
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCDeviceAssets."
    $endpoint = "api/devices/$DeviceId/assets"

    try {
        Write-Verbose "[FUNCTION] Retrieving device assests with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving device assests: $_"
    }
}