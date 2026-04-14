<#
.SYNOPSIS
Partially updates a device's asset-lifecycle record.

.DESCRIPTION
PATCH /api/devices/{deviceId}/assets/lifecycle-info. Only supplied fields are sent to the API.

.EXAMPLE
Update-NCAssetLifecycle -DeviceId 987 -Location 'Branch office'
#>
function Update-NCAssetLifecycle {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [string]$AssetTag,
        [Nullable[decimal]]$Cost,
        [string]$Description,
        [string]$ExpectedReplacementDate,
        [string]$LeaseExpiryDate,
        [string]$Location,
        [string]$PurchaseDate,
        [string]$WarrantyExpiryDate
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('AssetTag'))                { $body.assetTag                = $AssetTag }
        if ($PSBoundParameters.ContainsKey('Cost'))                    { $body.cost                    = $Cost }
        if ($PSBoundParameters.ContainsKey('Description'))             { $body.description             = $Description }
        if ($PSBoundParameters.ContainsKey('ExpectedReplacementDate')) { $body.expectedReplacementDate = $ExpectedReplacementDate }
        if ($PSBoundParameters.ContainsKey('LeaseExpiryDate'))         { $body.leaseExpiryDate         = $LeaseExpiryDate }
        if ($PSBoundParameters.ContainsKey('Location'))                { $body.location                = $Location }
        if ($PSBoundParameters.ContainsKey('PurchaseDate'))            { $body.purchaseDate            = $PurchaseDate }
        if ($PSBoundParameters.ContainsKey('WarrantyExpiryDate'))      { $body.warrantyExpiryDate      = $WarrantyExpiryDate }

        if (-not $PSCmdlet.ShouldProcess($DeviceId, 'Patch asset lifecycle record')) { return }
        $api.Patch("api/devices/$DeviceId/assets/lifecycle-info", $body)
    }
}
