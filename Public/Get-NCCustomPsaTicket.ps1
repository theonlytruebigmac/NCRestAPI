<#
.SYNOPSIS
Retrieves details for a specific Custom-PSA ticket.

.DESCRIPTION
POST /api/custom-psa/tickets/{customPsaTicketId}. The spec defines this as POST with a
PSA credential body.

.PARAMETER CustomPsaTicketId
Ticket ID.

.PARAMETER Credential
PSCredential containing username and password for the PSA integration.

.EXAMPLE
Get-NCCustomPsaTicket -CustomPsaTicketId 'TKT-42' -Credential (Get-Credential)
#>
function Get-NCCustomPsaTicket {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomPsaTicketId,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCCustomPsaTicket: invoked."
        $body = @{
            username = $Credential.UserName
            password = $Credential.GetNetworkCredential().Password
        }
        $api.Post("api/custom-psa/tickets/$CustomPsaTicketId", $body)
    }
}
