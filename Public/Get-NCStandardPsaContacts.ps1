<#
.SYNOPSIS
Retrieves PSA contacts for a customer and PSA company.

.DESCRIPTION
GET /api/standard-psa/customers/{customerId}/companies/{psaCompanyId}/contacts.

.PARAMETER CustomerId
Customer ID.

.PARAMETER PsaCompanyId
PSA company ID.

.EXAMPLE
Get-NCStandardPsaContacts -CustomerId 100 -PsaCompanyId 5
#>
function Get-NCStandardPsaContacts {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$PsaCompanyId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCStandardPsaContacts: api/standard-psa/customers/$CustomerId/companies/$PsaCompanyId/contacts"
        $api.Get("api/standard-psa/customers/$CustomerId/companies/$PsaCompanyId/contacts")
    }
}
