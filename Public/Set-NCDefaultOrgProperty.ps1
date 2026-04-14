<#
.SYNOPSIS
Sets a default organization custom property.

.DESCRIPTION
PUT /api/org-units/{orgUnitId}/org-custom-property-defaults. Matches the
`DefaultCustomPropertyModifyRequest` schema: propagate, propertyId, propertyName,
propagationType, defaultValue, selectedOrgUnitIds, enumeratedValueList.

.PARAMETER OrgUnitId
Org unit that owns the default.

.PARAMETER PropertyId
Property ID to modify.

.PARAMETER PropertyName
Property name.

.PARAMETER PropagationType
How the change propagates down the org tree.

.PARAMETER DefaultValue
Default value to set.

.PARAMETER Propagate
Propagate the change to descendants.

.PARAMETER SelectedOrgUnitIds
Targeted org units the change should apply to.

.PARAMETER EnumeratedValueList
Allowed values (for enumerated properties).

.EXAMPLE
Set-NCDefaultOrgProperty -OrgUnitId 1 -PropertyId 5 -PropertyName 'region' `
    -PropagationType SERVICE_ORGANIZATION_AND_CUSTOMER -DefaultValue 'US'
#>
function Set-NCDefaultOrgProperty {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory)]
        [int]$PropertyId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            'NO_PROPAGATION',
            'SERVICE_ORGANIZATION_ONLY',
            'SERVICE_ORGANIZATION_AND_CUSTOMER_AND_SITE',
            'SERVICE_ORGANIZATION_AND_CUSTOMER',
            'SERVICE_ORGANIZATION_AND_SITE',
            'CUSTOMER_AND_SITE',
            'CUSTOMER_ONLY',
            'SITE_ONLY',
            'SERVICE_AND_ORGANIZATION',
            'SERVICE_AND_ORGANIZATION_AND_DEVICE',
            'SERVICE_AND_DEVICE',
            'ORGANIZATION_AND_DEVICE',
            'ORGANIZATION_ONLY',
            'DEVICE_ONLY'
        )]
        [string]$PropagationType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultValue,

        [switch]$Propagate,

        [int[]]$SelectedOrgUnitIds,

        [string[]]$EnumeratedValueList
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Set-NCDefaultOrgProperty: invoked."
        $body = [ordered]@{
            propagate       = [bool]$Propagate
            propertyId      = $PropertyId
            propertyName    = $PropertyName
            propagationType = $PropagationType
            defaultValue    = $DefaultValue
        }
        if ($SelectedOrgUnitIds)   { $body.selectedOrgUnitIds  = $SelectedOrgUnitIds }
        if ($EnumeratedValueList)  { $body.enumeratedValueList = $EnumeratedValueList }

        if (-not $PSCmdlet.ShouldProcess($OrgUnitId, 'Set default org property')) { return }
        $api.Put("api/org-units/$OrgUnitId/org-custom-property-defaults", $body)
    }
}
