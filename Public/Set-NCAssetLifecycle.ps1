<#
.SYNOPSIS
Replaces a device's full asset-lifecycle record.

.DESCRIPTION
PUT /api/devices/{deviceId}/assets/lifecycle-info. All fields in the spec
(`AssetLifecyclePutRequest`) are required; nulls must be sent explicitly. Use
`Update-NCAssetLifecycle` (PATCH) for partial updates.

.EXAMPLE
Set-NCAssetLifecycle -DeviceId 987 -AssetTag 'A-123' -Cost 1200 -Description 'Laptop' `
    -ExpectedReplacementDate '2028-01-01' -LeaseExpiryDate '2027-01-01' `
    -Location 'HQ' -PurchaseDate '2024-01-01' -WarrantyExpiryDate '2027-01-01'
#>
function Set-NCAssetLifecycle {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory)][string]$AssetTag,
        [Parameter(Mandatory)][decimal]$Cost,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$ExpectedReplacementDate,
        [Parameter(Mandatory)][string]$LeaseExpiryDate,
        [Parameter(Mandatory)][string]$Location,
        [Parameter(Mandatory)][string]$PurchaseDate,
        [Parameter(Mandatory)][string]$WarrantyExpiryDate,

        [switch]$AllNull
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $body = @{
            assetTag                = $AssetTag
            cost                    = $Cost
            description             = $Description
            expectedReplacementDate = $ExpectedReplacementDate
            leaseExpiryDate         = $LeaseExpiryDate
            location                = $Location
            purchaseDate            = $PurchaseDate
            warrantyExpiryDate      = $WarrantyExpiryDate
            allNull                 = [bool]$AllNull
        }
        if (-not $PSCmdlet.ShouldProcess($DeviceId, 'Replace asset lifecycle record')) { return }
        $api.Put("api/devices/$DeviceId/assets/lifecycle-info", $body)
    }
}
