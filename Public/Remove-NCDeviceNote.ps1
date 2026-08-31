<#
.SYNOPSIS
Deletes notes from a device.

.DESCRIPTION
DELETE /api/devices/{deviceId}/notes/{noteId} for a single note, or
DELETE /api/devices/{deviceId}/notes with a body of noteIds for batch deletion.

.PARAMETER DeviceId
Target device.

.PARAMETER NoteId
Single note to delete.

.PARAMETER NoteIds
Array of note IDs to delete in batch.

.PARAMETER Force
Skip the confirmation prompt.

.EXAMPLE
Remove-NCDeviceNote -DeviceId 987 -NoteId 'abc' -Force

.EXAMPLE
Remove-NCDeviceNote -DeviceId 987 -NoteIds 'abc','def'
#>
function Remove-NCDeviceNote {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Single')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Single', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$NoteId,

        [Parameter(Mandatory, ParameterSetName = 'Batch')]
        [object[]]$NoteIds,

        [switch]$Force
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Batch') {
            $target = $NoteIds -join ','
            if ($Force -or $PSCmdlet.ShouldProcess($target, "Delete notes from device $DeviceId")) {
                Write-Verbose "[FUNCTION] Remove-NCDeviceNote: DELETE api/devices/$DeviceId/notes (batch)"
                $api.Delete("api/devices/$DeviceId/notes", @{ noteIds = $NoteIds })
            }
            return
        }

        if ($Force -or $PSCmdlet.ShouldProcess($NoteId, "Delete note from device $DeviceId")) {
            Write-Verbose "[FUNCTION] Remove-NCDeviceNote: DELETE api/devices/$DeviceId/notes/$NoteId"
            $api.Delete("api/devices/$DeviceId/notes/$NoteId")
        }
    }
}
