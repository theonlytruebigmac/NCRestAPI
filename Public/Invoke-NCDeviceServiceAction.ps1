<#
.SYNOPSIS
Performs an action on Windows Services for a device.

.DESCRIPTION
POST /api/devices/{deviceId}/services/actions.

.PARAMETER DeviceId
Target device.

.PARAMETER ServiceNames
Array of Windows service names to act on.

.PARAMETER Action
Action to perform (e.g. Start, Stop, Restart).

.EXAMPLE
Invoke-NCDeviceServiceAction -DeviceId 987 -ServiceNames 'Spooler' -Action 'Restart'
#>
function Invoke-NCDeviceServiceAction {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory)]
        [string[]]$ServiceNames,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Action
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Invoke-NCDeviceServiceAction: POST api/devices/$DeviceId/services/actions"
        $body = @{
            serviceNames = $ServiceNames
            action       = $Action
        }
        if (-not $PSCmdlet.ShouldProcess("$($ServiceNames -join ',') on $DeviceId", "$Action Windows service(s)")) { return }
        $api.Post("api/devices/$DeviceId/services/actions", $body)
    }
}
