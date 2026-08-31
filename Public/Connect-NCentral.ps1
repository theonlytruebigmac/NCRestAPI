<#
.SYNOPSIS
Establishes a connection to an N-central server.

.DESCRIPTION
Wrapper around Set-NCRestConfig that follows the PowerShell Connect-* convention.
Supports both API token and SSO token authentication.

.PARAMETER BaseUrl
Fully-qualified URL of the N-central server (https:// scheme added if omitted).

.PARAMETER ApiToken
User-level API token. Accepts [string] or [securestring].

.PARAMETER SsoToken
SSO access token from an external identity provider. Accepts [string] or [securestring].

.PARAMETER AccessTokenExpiration
Override access-token lifetime (e.g. '1h', '120s'). Default '1h'.

.PARAMETER RefreshTokenExpiration
Override refresh-token lifetime (e.g. '25h'). Default '25h'.

.PARAMETER PassThru
Emit the connection info object after authenticating.

.EXAMPLE
Connect-NCentral -BaseUrl 'n-central.example.com' -ApiToken $token

.EXAMPLE
Connect-NCentral -BaseUrl 'n-central.example.com' -SsoToken $ssoToken -PassThru
#>
function Connect-NCentral {
    [CmdletBinding(DefaultParameterSetName = 'ApiToken')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BaseUrl,

        [Parameter(Mandatory, ParameterSetName = 'ApiToken')]
        [ValidateNotNullOrEmpty()]
        [object]$ApiToken,

        [Parameter(Mandatory, ParameterSetName = 'SsoToken')]
        [ValidateNotNullOrEmpty()]
        [object]$SsoToken,

        [ValidatePattern('^\d+[smh]$')]
        [string]$AccessTokenExpiration = '1h',

        [ValidatePattern('^\d+[smh]$')]
        [string]$RefreshTokenExpiration = '25h',

        [ValidateRange(1, 600)]
        [int]$TimeoutSec = 60,

        [ValidateRange(0, 10)]
        [int]$MaxRetries = 3,

        [ValidateRange(0, 60000)]
        [int]$ThrottleMs = 0,

        [switch]$PassThru
    )

    Write-Verbose "[FUNCTION] Connect-NCentral: invoked."
    $setParams = @{} + $PSBoundParameters
    $null = $setParams.Remove('PassThru')
    Set-NCRestConfig @setParams
    if ($PassThru) { return Get-NCRestApiInfo }
}
