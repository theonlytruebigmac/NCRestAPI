<#
.SYNOPSIS
Updates standard-PSA customer mappings.

.DESCRIPTION
PUT /api/standard-psa/customer/{customerId}/mappings.

.PARAMETER CustomerId
Customer ID.

.PARAMETER PsaCompanyId
PSA company ID to map.

.PARAMETER PsaSiteId
Optional PSA site ID.

.PARAMETER PsaContactId
Optional PSA contact ID.

.EXAMPLE
Set-NCStandardPsaCustomerMapping -CustomerId 100 -PsaCompanyId 5
#>
function Set-NCStandardPsaCustomerMapping {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$CustomerId,

        [int]$PsaCompanyId,
        [int]$PsaSiteId,
        [int]$PsaContactId
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Set-NCStandardPsaCustomerMapping: PUT api/standard-psa/customer/$CustomerId/mappings"
        $body = @{ customerId = $CustomerId }
        if ($PSBoundParameters.ContainsKey('PsaCompanyId')) { $body.psaCompanyId = $PsaCompanyId }
        if ($PSBoundParameters.ContainsKey('PsaSiteId'))    { $body.psaSiteId    = $PsaSiteId }
        if ($PSBoundParameters.ContainsKey('PsaContactId')) { $body.psaContactId = $PsaContactId }
        if (-not $PSCmdlet.ShouldProcess($CustomerId, 'Update standard PSA customer mapping')) { return }
        $api.Put("api/standard-psa/customer/$CustomerId/mappings", $body)
    }
}
