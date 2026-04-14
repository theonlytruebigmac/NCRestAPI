<#
.SYNOPSIS
Retrieves registration tokens from the N-central API.

.DESCRIPTION
Uses mutually-exclusive parameter sets for the three token-bearing endpoints:
`/api/customers/{id}/registration-token`, `/api/sites/{id}/registration-token`, and
`/api/org-units/{id}/registration-token`.

.EXAMPLE
Get-NCRegTokens -CustId 123

.EXAMPLE
Get-NCCustomers -All | Get-NCRegTokens

.EXAMPLE
Get-NCSites -All | Get-NCRegTokens
#>
function Get-NCRegTokens {
    [CmdletBinding(DefaultParameterSetName = 'Customer')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Customer', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('customerId')]
        [string]$CustId,

        [Parameter(Mandatory, ParameterSetName = 'Site', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteId,

        [Parameter(Mandatory, ParameterSetName = 'OrgUnit', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        $endpoint = switch ($PSCmdlet.ParameterSetName) {
            'Customer' { "api/customers/$CustId/registration-token" }
            'Site'     { "api/sites/$SiteId/registration-token" }
            'OrgUnit'  { "api/org-units/$OrgUnitId/registration-token" }
        }
        Write-Verbose "[FUNCTION] Get-NCRegTokens: $endpoint"
        $api.Get($endpoint)
    }
}
