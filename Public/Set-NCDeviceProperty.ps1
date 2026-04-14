<#
.SYNOPSIS
Updates a custom property on a device.

.DESCRIPTION
PUT /api/devices/{deviceId}/custom-properties/{propertyId}. All body fields in the
`DeviceCustomPropertyModification` schema are supported; only bound parameters are sent.

.PARAMETER DeviceId
Target device.

.PARAMETER PropertyId
Custom-property ID.

.PARAMETER Value
New property value.

.PARAMETER PropertyName
Optional new property name.

.PARAMETER PropertyType
Optional new property type.

.PARAMETER EnumeratedValueList
Optional list of allowed values (for enumerated properties).

.EXAMPLE
Set-NCDeviceProperty -DeviceId 123 -PropertyId 7 -Value 'production'
#>
function Set-NCDeviceProperty {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

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

        if (-not $PSCmdlet.ShouldProcess("$DeviceId/$PropertyId", 'Set device custom property')) { return }
        $api.Put("api/devices/$DeviceId/custom-properties/$PropertyId", $body)
    }
}
