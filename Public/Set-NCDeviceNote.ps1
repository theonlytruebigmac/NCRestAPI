<#
.SYNOPSIS
Modifies a note on a device.

.DESCRIPTION
PUT /api/devices/{deviceId}/notes/{noteId}.

.PARAMETER DeviceId
Target device.

.PARAMETER NoteId
Note to modify.

.PARAMETER Note
New note text.

.EXAMPLE
Set-NCDeviceNote -DeviceId 987 -NoteId 'abc' -Note 'Updated text'
#>
function Set-NCDeviceNote {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$NoteId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Note
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] Set-NCDeviceNote: PUT api/devices/$DeviceId/notes/$NoteId"
        if (-not $PSCmdlet.ShouldProcess("$DeviceId/$NoteId", 'Modify device note')) { return }
        $api.Put("api/devices/$DeviceId/notes/$NoteId", @{ note = $Note })
    }
}
