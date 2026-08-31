<#
.SYNOPSIS
Configures the NCRestAPI module and establishes a connection to the N-central server.

.DESCRIPTION
Stores the base URL, API token (or SSO token), and optional token-expiration overrides,
then authenticates and caches a module-scoped NCRestAPI instance that subsequent cmdlets reuse.

.PARAMETER BaseUrl
Fully-qualified URL of the N-central server (https:// scheme added if omitted).

.PARAMETER ApiToken
User-level API token from N-central. Accepts [string] or [securestring].

.PARAMETER SsoToken
SSO access token from an external identity provider. Accepts [string] or [securestring].
Uses POST /api/auth/sso instead of /api/auth/authenticate.

.PARAMETER AccessTokenExpiration
Access-token lifetime override (e.g. '120s', '30m', '1h'). Default '1h'.

.PARAMETER RefreshTokenExpiration
Refresh-token lifetime override (e.g. '25h'). Default '25h'.

.PARAMETER TimeoutSec
Per-request timeout in seconds. Default 60.

.PARAMETER MaxRetries
Maximum retries on HTTP 429 / 5xx / transport errors. Default 3.

.PARAMETER ThrottleMs
Minimum spacing between successive requests in milliseconds. 0 (default) means no
client-side throttle. Useful during large `-All` pulls or pipeline fan-out against
rate-limited tenants.

.EXAMPLE
Set-NCRestConfig -BaseUrl 'n-central.example.com' -ApiToken $token

.EXAMPLE
Set-NCRestConfig -BaseUrl ... -ApiToken ... -ThrottleMs 200 -MaxRetries 5

.NOTES
Author: Zach Frazier
#>
function Set-NCRestConfig {
    [CmdletBinding(DefaultParameterSetName = 'ApiToken')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BaseUrl,

        [Parameter(Mandatory, ParameterSetName = 'ApiToken')]
        [object]$ApiToken,

        [Parameter(Mandatory, ParameterSetName = 'SsoToken')]
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
        [int]$ThrottleMs = 0
    )

    if ($BaseUrl -notmatch '^https?://') { $BaseUrl = 'https://' + $BaseUrl }
    $BaseUrl = $BaseUrl.TrimEnd('/')

    $useSso = $PSCmdlet.ParameterSetName -eq 'SsoToken'
    $rawToken = if ($useSso) { $SsoToken } else { $ApiToken }

    if ($rawToken -is [securestring]) {
        $secureToken = $rawToken
    } elseif ($rawToken -is [string]) {
        $secureToken = [NCRestAPI]::ToSecureString($rawToken)
    } else {
        throw "Token must be [string] or [securestring]."
    }

    $authLabel = if ($useSso) { 'SSO' } else { 'API token' }
    Write-Verbose "[NCRESTCONFIG] Creating NCRestAPI instance for $BaseUrl ($authLabel)."
    $instance = [NCRestAPI]::new($BaseUrl, $secureToken, $AccessTokenExpiration, $RefreshTokenExpiration, ($VerbosePreference -eq 'Continue'), $useSso)
    $instance.TimeoutSec = $TimeoutSec
    $instance.MaxRetries = $MaxRetries
    $instance.ThrottleMs = $ThrottleMs

    # Dispose prior instance so its SecureString tokens are zeroed before we
    # drop the reference — important when reconfiguring (tenant switch, reauth).
    $prior = $script:NCRestApiInstance
    if (-not $prior) { $prior = $global:NCRestApiInstance }
    if ($prior -and $prior -ne $instance) {
        try { $prior.Dispose() } catch { Write-Verbose "[NCRESTCONFIG] prior Dispose() threw: $($_.Exception.Message)" }
    }

    # Module scope is the source of truth; global mirror lets scripts dot-sourced
    # outside the module (no module session state) still pick up the instance.
    $script:NCRestApiInstance = $instance
    $global:NCRestApiInstance = $instance
}
