<#
.SYNOPSIS
Retrieves the default device property from the N-central API.

.DESCRIPTION
The `Get-NCDefaultDeviceProperty` function retrieves the default device property from the N-central API. 
It requires both an organization unit ID and a property ID to specify the device property to be retrieved.

.PARAMETER OrgUnitId
The organization unit ID for the device property. This parameter is mandatory.

.PARAMETER PropertyId
The property ID for the device property. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCDefaultDeviceProperty -OrgUnitId 123 -PropertyId 456 -Verbose
Retrieves the default device property for the organization unit ID 123 and property ID 456 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the default device property data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function Get-NCDefaultDeviceProperty {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyId
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Get-NCDefaultDeviceProperty: api/org-units/$OrgUnitId/custom-properties/device-custom-property-defaults/$PropertyId"
        $api.Get("api/org-units/$OrgUnitId/custom-properties/device-custom-property-defaults/$PropertyId")
    }
}
