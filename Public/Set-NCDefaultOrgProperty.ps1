<#
.SYNOPSIS
Sets a default organization property in the N-central API.

.DESCRIPTION
The `Set-NCDefaultOrgProperty` function sets a default organization property in the N-central API.
It requires parameters to specify the organization unit ID, property ID, property name, propagation type, and value.
Optional parameters include whether to propagate the change and an array of selected organization unit IDs.

.PARAMETER OrgUnitId
The organization unit ID where the property will be set. This parameter is mandatory.

.PARAMETER PropertyId
The ID of the property to be set. This parameter is mandatory.

.PARAMETER PropertyName
The name of the property to be set. This parameter is mandatory.

.PARAMETER PropagationType
The type of propagation for the property. This parameter is mandatory.

.PARAMETER Value
The value to be set for the property. This parameter is mandatory.

.PARAMETER Propagate
Specifies whether the property change should be propagated. The default value is $false.

.PARAMETER SelectedOrgUnitIds
An array of organization unit IDs to which the property change should be propagated.

.EXAMPLE
PS C:\> Set-NCDefaultOrgProperty -OrgUnitId 123 -PropertyId 456 -PropertyName "Custom Property" -PropagationType "Type" -Value "New Value" -Verbose
Sets a default organization property with the specified details and enables verbose output.

.EXAMPLE
PS C:\> Set-NCDefaultOrgProperty -OrgUnitId 123 -PropertyId 456 -PropertyName "Custom Property" -PropagationType "Type" -Value "New Value" -Propagate $true -SelectedOrgUnitIds @(789, 101112) -Verbose
Sets a default organization property with the specified details, propagates the change to the selected organization units, and enables verbose output.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after setting the default organization property.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Set-NCDefaultOrgProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$OrgUnitId,

        [Parameter(Mandatory = $true)]
        [int]$PropertyId,

        [Parameter(Mandatory = $true)]
        [string]$PropertyName,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "NO_PROPAGATION", 
            "SERVICE_ORGANIZATION_ONLY", 
            "SERVICE_ORGANIZATION_AND_CUSTOMER_AND_SITE", 
            "SERVICE_ORGANIZATION_AND_CUSTOMER", 
            "SERVICE_ORGANIZATION_AND_SITE", 
            "CUSTOMER_AND_SITE", 
            "CUSTOMER_ONLY", 
            "SITE_ONLY", 
            "SERVICE_AND_ORGANIZATION", 
            "SERVICE_AND_ORGANIZATION_AND_DEVICE", 
            "SERVICE_AND_DEVICE", 
            "ORGANIZATION_AND_DEVICE", 
            "ORGANIZATION_ONLY", 
            "DEVICE_ONLY"
        )]
        [string]$PropagationType,

        [Parameter(Mandatory = $true)]
        [string]$Value,

        [ValidateSet($true, $false)]
        [bool]$Propagate = $false,

        [int[]]$SelectedOrgUnitIds
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Set-NCDefaultOrgProperty."
    $body = [ordered]@{
        propagate       = $Propagate
        propertyId      = $PropertyId
        propertyName    = $PropertyName
        orgUnitId       = $OrgUnitId
        propagationType = $PropagationType
        defaultValue           = $Value
    }

    if ($SelectedOrgUnitIds) {
        $body["selectedOrgUnitIds"] = $SelectedOrgUnitIds
    }

    $endpoint = "api/org-units/$OrgUnitId/org-custom-property-defaults"

    $bodyJson = $body | ConvertTo-Json -Depth 10

    try {
        Write-Verbose "[FUNCTION] Setting Default Orgnization Property to $endpoint."
        $response = $api.Put($endpoint, $bodyJson)
        return $response
    }
    catch {
        Write-Error "Error setting default organization property: $_"
    }
}