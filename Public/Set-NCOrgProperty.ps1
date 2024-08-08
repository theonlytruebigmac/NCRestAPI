<#
.SYNOPSIS
Sets a custom property for an organization unit in the N-central API.

.DESCRIPTION
The `Set-NCOrgProperty` function sets a custom property for an organization unit in the N-central API.
It requires parameters to specify the organization unit ID, property ID, and value.

.PARAMETER OrgUnitId
The organization unit ID for which the property will be set. This parameter is mandatory.

.PARAMETER PropertyId
The ID of the property to be set. This parameter is mandatory.

.PARAMETER Value
The value to be set for the property. This parameter is mandatory.

.EXAMPLE
PS C:\> Set-NCOrgProperty -OrgUnitId 123 -PropertyId 456 -Value "New Value" -Verbose
Sets a custom property for the organization unit with the ID 123 and property ID 456 with the value "New Value", with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after setting the organization property.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Set-NCOrgProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$OrgUnitId,

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
    
    Write-Verbose "[FUNCTION] Running Set-NCOrgProperty."
    $body = @{
        value = $Value
    }

    $endpoint = "api/org-units/$OrgUnitId/custom-properties/$PropertyId"

    $bodyJson = $body | ConvertTo-Json -Depth 10

    try {
        Write-Verbose "[FUNCTION] Setting organization property with endpoint: $endpoint."
        $response = $api.Put($endpoint, $bodyJson)
        return $response
    }
    catch {
        Write-Error "Error setting organization property: $_"
    }
}