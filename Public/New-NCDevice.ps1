<#
.SYNOPSIS
Registers a new device in N-central.

.DESCRIPTION
POST /api/device with a `DeviceAddRequest` body. Username/password are taken from a
PSCredential to avoid plaintext parameters.

.PARAMETER CustomerId
Customer the device belongs to.

.PARAMETER DeviceClass
Device class (string per the spec).

.PARAMETER LongName
Friendly name.

.PARAMETER NetworkAddress
URI or IP address.

.PARAMETER SupportedOs
Operating system supported by the device.

.PARAMETER Description
Optional short description.

.PARAMETER LicenseMode
Optional license mode.

.PARAMETER MacAddress
Optional MAC address.

.PARAMETER Credential
Optional PSCredential for device authentication (replaces username/password pair in the spec).

.EXAMPLE
New-NCDevice -CustomerId 100 -DeviceClass 'Server' -LongName 'db01' `
    -NetworkAddress '10.0.0.10' -SupportedOs 'Windows'
#>
function New-NCDevice {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId,

        [Parameter(Mandatory)][string]$DeviceClass,
        [Parameter(Mandatory)][string]$LongName,
        [Parameter(Mandatory)][string]$NetworkAddress,
        [Parameter(Mandatory)][string]$SupportedOs,

        [string]$Description,
        [string]$LicenseMode,
        [string]$MacAddress,
        [pscredential]$Credential
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] New-NCDevice: invoked."
        $body = @{
            customerId     = $CustomerId
            deviceClass    = $DeviceClass
            longName       = $LongName
            networkAddress = $NetworkAddress
            supportedOs    = $SupportedOs
        }
        if ($Description) { $body.description = $Description }
        if ($LicenseMode) { $body.licenseMode = $LicenseMode }
        if ($MacAddress)  { $body.macAddress  = $MacAddress }
        if ($Credential) {
            $body.username = $Credential.UserName
            $body.password = $Credential.GetNetworkCredential().Password
        }
        if (-not $PSCmdlet.ShouldProcess($LongName, 'Register new device')) { return }
        $api.Post('api/device', $body)
    }
}
