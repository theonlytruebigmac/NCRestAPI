<#
.SYNOPSIS
Retrieves the default organization property from the N-central API.

.DESCRIPTION
The `Get-NCDefaultOrgProperty` function retrieves the default organization property from the N-central API. 
It requires both an organization unit ID and a property ID to specify the organization property to be retrieved.

.PARAMETER OrgUnitId
The organization unit ID for the organization property. This parameter is mandatory.

.PARAMETER PropertyId
The property ID for the organization property. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCDefaultOrgProperty -OrgUnitId 123 -PropertyId 456 -Verbose
Retrieves the default organization property for the organization unit ID 123 and property ID 456 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the default organization property data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCDefaultOrgProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$OrgUnitId,

        [Parameter(Mandatory = $true)]
        [int]$PropertyId
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCDefaultOrgProperty."
    $endpoint = "api/org-units/$OrgUnitId/org-custom-property-defaults/$propertyId"

    try {
        Write-Verbose "[FUNCTION] Retrieving default organization property with endpoint: $endpoint."
        $response = $api.Get($endpoint)
        return $response
    }
    catch {
        Write-Error "Error retrieving default organization property: $_"
    }
}