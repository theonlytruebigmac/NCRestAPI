<#
.SYNOPSIS
Retrieves PSA companies for a customer.

.DESCRIPTION
GET /api/standard-psa/customers/{customerId}/companies.

.PARAMETER CustomerId
Customer ID.

.EXAMPLE
Get-NCStandardPsaCompanies -CustomerId 100
#>
function Get-NCStandardPsaCompanies {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCStandardPsaCompanies: api/standard-psa/customers/$CustomerId/companies"
        $api.Get("api/standard-psa/customers/$CustomerId/companies")
    }
}
