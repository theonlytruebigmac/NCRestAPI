<#
.SYNOPSIS
Adds a note to one or more devices.

.DESCRIPTION
POST /api/devices/{deviceId}/notes for a single device, or
POST /api/devices/notes for multiple devices.

.PARAMETER DeviceId
Single device to add the note to. Use -DeviceIds for multiple.

.PARAMETER DeviceIds
Array of device IDs to add the note to (bulk endpoint).

.PARAMETER UserId
The user ID associated with the note.

.PARAMETER Note
The note text.

.PARAMETER InsertionTime
Optional ISO 8601 timestamp for the note.

.EXAMPLE
New-NCDeviceNote -DeviceId 987 -UserId 1 -Note 'Replaced hard drive'

.EXAMPLE
New-NCDeviceNote -DeviceIds 100,200,300 -UserId 1 -Note 'Scheduled for maintenance'
#>
function New-NCDeviceNote {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Single')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Single', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Bulk')]
        [object[]]$DeviceIds,

        [Parameter(Mandatory)]
        [int]$UserId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Note,

        [string]$InsertionTime
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Bulk') {
            Write-Verbose "[FUNCTION] New-NCDeviceNote: POST api/devices/notes (bulk)"
            $body = @{
                deviceIds = $DeviceIds
                userId    = $UserId
                note      = $Note
            }
            if ($InsertionTime) { $body.insertionTime = $InsertionTime }
            if (-not $PSCmdlet.ShouldProcess(($DeviceIds -join ','), 'Add note to devices')) { return }
            return $api.Post('api/devices/notes', $body)
        }

        Write-Verbose "[FUNCTION] New-NCDeviceNote: POST api/devices/$DeviceId/notes"
        $body = @{
            userId = $UserId
            note   = $Note
        }
        if ($InsertionTime) { $body.insertionTime = $InsertionTime }
        if (-not $PSCmdlet.ShouldProcess($DeviceId, 'Add note to device')) { return }
        $api.Post("api/devices/$DeviceId/notes", $body)
    }
}
