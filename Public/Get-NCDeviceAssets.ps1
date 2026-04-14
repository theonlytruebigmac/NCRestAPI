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
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function Get-NCDeviceAssets {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId
    )

    begin { $api = Get-NCRestApiInstance }



    process {
    Write-Verbose "[FUNCTION] Get-NCDeviceAssets: invoked."
    $endpoint = "api/devices/$DeviceId/assets"

        Write-Verbose "[FUNCTION] Retrieving device assets with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data


    }
}
