<#
.SYNOPSIS
Retrieves registration tokens from the N-central API.

.DESCRIPTION
The `Get-NCRegTokens` function retrieves registration tokens from the N-central API.
It requires exactly one of the following parameters to specify the scope of the tokens to be retrieved: customer ID, site ID, or organization unit ID.

.PARAMETER CustId
The customer ID to retrieve registration tokens for.

.PARAMETER SiteId
The site ID to retrieve registration tokens for.

.PARAMETER OrgUnitId
The organization unit ID to retrieve registration tokens for.

.EXAMPLE
PS C:\> Get-NCRegTokens -CustId 123 -Verbose
Retrieves registration tokens for the customer ID 123 with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCRegTokens -SiteId 456
Retrieves registration tokens for the site ID 456.

.EXAMPLE
PS C:\> Get-NCRegTokens -OrgUnitId 789 -Verbose
Retrieves registration tokens for the organization unit ID 789 with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns registration token data from the N-central API.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCRegTokens {
    [CmdletBinding()]
    param (
        [int]$CustId,

        [int]$SiteId,

        [int]$OrgUnitId
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running Get-NCRegTokens."
    $providedParams = @($CustId, $SiteId, $OrgUnitId) | Where-Object { $_ }
    if ($providedParams.Count -ne 1) {
        Write-Error "You must provide exactly one of the following parameters: CustId, SiteId, OrgUnitId."
        return
    }

    if ($CustId) {
        Write-Verbose "[FUNCTION] Retrieving registration tokens for customer ID $CustId."
        $endpoint = "api/customers/$CustId/registration-token"
    }
    elseif ($SiteId) {
        Write-Verbose "[FUNCTION] Retrieving registration tokens for site ID $SiteId."
        $endpoint = "api/sites/$SiteId/registration-token"
    }
    elseif ($OrgUnitId) {
        Write-Verbose "[FUNCTION] Retrieving registration tokens for organization unit ID $OrgUnitId."
        $endpoint = "api/org-units/$OrgUnitId/registration-token"
    }

    try {
        Write-Verbose "[FUNCTION] Retrieving registration tokens with endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving registration tokens: $_"
    }
}
