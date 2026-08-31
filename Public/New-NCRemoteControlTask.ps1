<#
.SYNOPSIS
Creates a remote-control task for a device.

.DESCRIPTION
POST /api/devices/{deviceId}/remote-control-task.

.PARAMETER DeviceId
Target device.

.PARAMETER RemoteControlType
Remote control type string.

.PARAMETER Description
Optional description.

.PARAMETER Port
Optional port number.

.EXAMPLE
New-NCRemoteControlTask -DeviceId 987 -RemoteControlType 'RDP'
#>
function New-NCRemoteControlTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$DeviceId,

        [string]$RemoteControlType,
        [string]$Description,
        [int]$Port
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] New-NCRemoteControlTask: POST api/devices/$DeviceId/remote-control-task"
        $body = @{}
        if ($RemoteControlType) { $body.remoteControlType = $RemoteControlType }
        if ($Description)       { $body.description       = $Description }
        if ($PSBoundParameters.ContainsKey('Port')) { $body.port = $Port }
        if (-not $PSCmdlet.ShouldProcess($DeviceId, 'Create remote control task')) { return }
        $api.Post("api/devices/$DeviceId/remote-control-task", $body)
    }
}
