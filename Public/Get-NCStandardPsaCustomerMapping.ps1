<#
.SYNOPSIS
Retrieves standard-PSA customer mappings for a given customer.

.DESCRIPTION
GET /api/standard-psa/customer/{customerId}/mappings.

.EXAMPLE
Get-NCStandardPsaCustomerMapping -CustomerId 100
#>
function Get-NCStandardPsaCustomerMapping {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCStandardPsaCustomerMapping: api/standard-psa/customer/$CustomerId/mappings"
        $api.Get("api/standard-psa/customer/$CustomerId/mappings")
    }
}
