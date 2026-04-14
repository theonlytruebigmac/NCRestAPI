<#
.SYNOPSIS
Submits a patch-comparison report request.

.DESCRIPTION
POST /api/report/patch-comparison. Returns a report ID that can be polled with Get-NCReport.

.PARAMETER StartDate
Start date for the comparison window (ISO 8601 string).

.PARAMETER InstallStatuses
Optional list of install statuses to include.

.PARAMETER PatchApprovals
Optional list of patch approval states to include.

.PARAMETER PatchCategories
Optional list of patch categories to include.

.EXAMPLE
$r = New-NCPatchComparisonReport -StartDate '2026-04-01'
Get-NCReport -ReportId $r.reportId
#>
function New-NCPatchComparisonReport {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)][string]$StartDate,
        [string[]]$InstallStatuses,
        [string[]]$PatchApprovals,
        [string[]]$PatchCategories
    )
    $api = Get-NCRestApiInstance
    $body = @{ startDate = $StartDate }
    if ($InstallStatuses) { $body.installStatuses = $InstallStatuses }
    if ($PatchApprovals)  { $body.patchApprovals  = $PatchApprovals }
    if ($PatchCategories) { $body.patchCategories = $PatchCategories }

    if (-not $PSCmdlet.ShouldProcess($StartDate, 'Submit patch-comparison report')) { return }
    $api.Post('api/report/patch-comparison', $body)
}
