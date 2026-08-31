<#
.SYNOPSIS
Creates a Custom PSA Ticket in N-central.

.DESCRIPTION
POST /api/custom-psa/tickets.

.PARAMETER PsaCustomTicketId
The PSA custom ticket ID.

.PARAMETER TicketNumber
The ticket number string.

.PARAMETER TicketUrl
The URL to the ticket in the PSA system.

.EXAMPLE
New-NCCustomPsaTicket -PsaCustomTicketId 42 -TicketNumber 'TKT-100' -TicketUrl 'https://psa.example.com/tickets/100'
#>
function New-NCCustomPsaTicket {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [int]$PsaCustomTicketId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TicketNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TicketUrl
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] New-NCCustomPsaTicket: invoked."
        $body = @{
            psaCustomTicketId = $PsaCustomTicketId
            ticketNumber      = $TicketNumber
            ticketUrl         = $TicketUrl
        }
        if (-not $PSCmdlet.ShouldProcess($TicketNumber, 'Create custom PSA ticket')) { return }
        $api.Post('api/custom-psa/tickets', $body)
    }
}
