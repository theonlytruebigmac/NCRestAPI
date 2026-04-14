<#
.SYNOPSIS
Retrieves a generated report by ID.

.DESCRIPTION
GET /api/report/{reportId}.

.EXAMPLE
Get-NCReport -ReportId 'abc-123'
#>
function Get-NCReport {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$ReportId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $api.Get("api/report/$ReportId")
    }
}
