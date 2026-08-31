<#
.SYNOPSIS
Retrieves PSA sites for a customer and PSA company.

.DESCRIPTION
GET /api/standard-psa/customers/{customerId}/companies/{psaCompanyId}/sites.

.PARAMETER CustomerId
Customer ID.

.PARAMETER PsaCompanyId
PSA company ID.

.EXAMPLE
Get-NCStandardPsaSites -CustomerId 100 -PsaCompanyId 5
#>
function Get-NCStandardPsaSites {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$CustomerId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$PsaCompanyId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCStandardPsaSites: api/standard-psa/customers/$CustomerId/companies/$PsaCompanyId/sites"
        $api.Get("api/standard-psa/customers/$CustomerId/companies/$PsaCompanyId/sites")
    }
}
