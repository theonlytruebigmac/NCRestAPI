<#
.SYNOPSIS
Reopens or resolves a Custom PSA Ticket in N-central.

.DESCRIPTION
POST /api/custom-psa/tickets/{id}/reopen or /resolve.

.PARAMETER CustomPsaTicketId
Ticket ID.

.PARAMETER Action
Action to perform: Reopen or Resolve.

.EXAMPLE
Invoke-NCCustomPsaTicket -CustomPsaTicketId 'TKT-42' -Action Reopen

.EXAMPLE
Invoke-NCCustomPsaTicket -CustomPsaTicketId 'TKT-42' -Action Resolve
#>
function Invoke-NCCustomPsaTicket {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomPsaTicketId,

        [Parameter(Mandatory)]
        [ValidateSet('Reopen', 'Resolve')]
        [string]$Action
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        $endpoint = if ($Action -eq 'Reopen') {
            "api/custom-psa/tickets/$CustomPsaTicketId/reopen"
        } else {
            "api/custom-psa/tickets/$CustomPsaTicketId/resolve"
        }
        Write-Verbose "[FUNCTION] Invoke-NCCustomPsaTicket: POST $endpoint"
        if (-not $PSCmdlet.ShouldProcess($CustomPsaTicketId, "$Action custom PSA ticket")) { return }
        $api.Post($endpoint, @{})
    }
}
