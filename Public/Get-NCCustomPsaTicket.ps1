<#
.SYNOPSIS
Retrieves details for a specific Custom-PSA ticket.

.DESCRIPTION
GET /api/custom-psa/tickets/{customPsaTicketId} returns the ticket without credentials.
Supply -Credential to use the POST variant which authenticates against the PSA integration.

.PARAMETER CustomPsaTicketId
Ticket ID.

.PARAMETER Credential
Optional PSCredential for the PSA integration. When omitted, the credential-free GET endpoint is used.

.EXAMPLE
Get-NCCustomPsaTicket -CustomPsaTicketId 'TKT-42'

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

        [pscredential]$Credential
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        if ($Credential) {
            Write-Verbose "[FUNCTION] Get-NCCustomPsaTicket: POST api/custom-psa/tickets/$CustomPsaTicketId"
            $body = @{
                username = $Credential.UserName
                password = $Credential.GetNetworkCredential().Password
            }
            return $api.Post("api/custom-psa/tickets/$CustomPsaTicketId", $body)
        }
        Write-Verbose "[FUNCTION] Get-NCCustomPsaTicket: GET api/custom-psa/tickets/$CustomPsaTicketId"
        $api.Get("api/custom-psa/tickets/$CustomPsaTicketId")
    }
}
