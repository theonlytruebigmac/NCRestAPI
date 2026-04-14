<#
.SYNOPSIS
Validates Standard-PSA credentials.

.DESCRIPTION
POST /api/standard-psa/{psaType}/credential with the supplied credential.

.PARAMETER PsaType
The PSA integration type (URL path segment).

.PARAMETER Credential
PSCredential with the username and password to validate.

.EXAMPLE
Test-NCStandardPsaCredential -PsaType 'connectwise' -Credential (Get-Credential)
#>
function Test-NCStandardPsaCredential {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PsaType,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )
    $api = Get-NCRestApiInstance
    $body = @{
        username = $Credential.UserName
        password = $Credential.GetNetworkCredential().Password
    }
    $api.Post("api/standard-psa/$PsaType/credential", $body)
}
