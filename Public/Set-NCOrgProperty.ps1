<#
.SYNOPSIS
Updates a custom property on an organization unit.

.DESCRIPTION
PUT /api/org-units/{orgUnitId}/custom-properties/{propertyId}. All body fields in the
`OrgUnitCustomPropertyModification` schema are supported; only bound parameters are sent.

.EXAMPLE
Set-NCOrgProperty -OrgUnitId 1 -PropertyId 5 -Value 'retailer'
#>
function Set-NCOrgProperty {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyId,

        [string]$Value,
        [string]$PropertyName,
        [string]$PropertyType,
        [string[]]$EnumeratedValueList
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Value'))               { $body.value               = $Value }
        if ($PSBoundParameters.ContainsKey('PropertyName'))        { $body.propertyName        = $PropertyName }
        if ($PSBoundParameters.ContainsKey('PropertyType'))        { $body.propertyType        = $PropertyType }
        if ($PSBoundParameters.ContainsKey('EnumeratedValueList')) { $body.enumeratedValueList = $EnumeratedValueList }

        if (-not $PSCmdlet.ShouldProcess("$OrgUnitId/$PropertyId", 'Set org custom property')) { return }
        $api.Put("api/org-units/$OrgUnitId/custom-properties/$PropertyId", $body)
    }
}
