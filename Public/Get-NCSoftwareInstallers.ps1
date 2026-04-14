<#
.SYNOPSIS
Lists software installers available for a customer.

.DESCRIPTION
GET /api/customers/{customerId}/software/installers.

.EXAMPLE
Get-NCSoftwareInstallers -CustomerId 100
#>
function Get-NCSoftwareInstallers {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId,

        [string]$SoftwareType,
        [string]$InstallerType
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $q = @{}
        if ($SoftwareType)  { $q['softwareType']  = $SoftwareType }
        if ($InstallerType) { $q['installerType'] = $InstallerType }
        $endpoint = "api/customers/$CustomerId/software/installers$(ConvertTo-NCQueryString -Parameters $q)"
        $api.Get($endpoint)
    }
}
