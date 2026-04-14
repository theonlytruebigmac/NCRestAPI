<#
.SYNOPSIS
Generates a software download link for a customer.

.DESCRIPTION
POST /api/customers/{customerId}/software/installers.

.EXAMPLE
New-NCSoftwareDownloadLink -CustomerId 100 -SoftwareId 'abc123'
#>
function New-NCSoftwareDownloadLink {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SoftwareId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        if (-not $PSCmdlet.ShouldProcess($CustomerId, "Generate download link for $SoftwareId")) { return }
        $api.Post("api/customers/$CustomerId/software/installers", @{ softwareId = $SoftwareId })
    }
}
