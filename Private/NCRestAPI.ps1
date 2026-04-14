<#
.SYNOPSIS
NCRestAPI class: handles authentication, token lifecycle, and HTTP requests against the N-central REST API.

.DESCRIPTION
Tokens are held in memory as [SecureString] and never written to environment variables or disk.
Plaintext is only materialized inside method calls via ConvertFromSecureString helpers that zero
unmanaged BSTR buffers. HTTP calls are funneled through a single Invoke() that retries on 429/5xx
with exponential backoff, propagates rich error information, and scrubs tokens from verbose output.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

class NCRestAPI {
    [string]$BaseUrl
    hidden [securestring]$ApiToken
    hidden [securestring]$AccessToken
    hidden [securestring]$RefreshToken
    [string]$AccessTokenExpiration
    [string]$RefreshTokenExpiration
    [int]$TimeoutSec = 60
    [int]$MaxRetries = 3
    # Client-side pacing between requests in ms. 0 = no throttle. Useful during
    # big -All pulls or pipeline fan-out against rate-limited tenants.
    [int]$ThrottleMs = 0
    [bool]$Verbose
    hidden [bool]$InPager = $false
    hidden [datetime]$LastRequestAt = [datetime]::MinValue

    NCRestAPI([string]$baseUrl, [securestring]$apiToken, [string]$accessTokenExpiration, [string]$refreshTokenExpiration, [bool]$verbose = $false) {
        $this.BaseUrl = $baseUrl
        $this.ApiToken = $apiToken
        $this.AccessTokenExpiration = $accessTokenExpiration
        $this.RefreshTokenExpiration = $refreshTokenExpiration
        $this.Verbose = $verbose
        $this.Authenticate()
    }

    static [securestring] ToSecureString([string]$plain) {
        $s = New-Object System.Security.SecureString
        foreach ($c in $plain.ToCharArray()) { $s.AppendChar($c) }
        $s.MakeReadOnly()
        return $s
    }

    hidden [string] Reveal([securestring]$s) {
        if (-not $s) { return $null }
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
        try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }

    hidden [void] Log([string]$message) {
        if (-not $this.Verbose) { return }
        $scrubbed = $message `
            -replace '(?i)(Bearer\s+)[A-Za-z0-9\-\._~\+\/=]+', '$1[MASKED]' `
            -replace '(?i)("(?:access|refresh|api)?token"\s*:\s*")[^"]+', '$1[MASKED]' `
            -replace '(?i)("token"\s*:\s*")[^"]+', '$1[MASKED]'
        Write-Verbose $scrubbed
    }

    hidden [hashtable] AuthHeaders([securestring]$token) {
        return @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.Reveal($token))"
            'Content-Type'  = 'application/json'
        }
    }

    [void] Authenticate() {
        $this.Log("[NCRESTAPI] Authenticate: starting.")
        $url = "$($this.BaseUrl)/api/auth/authenticate"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.Reveal($this.ApiToken))"
        }
        if ($this.RefreshTokenExpiration) { $headers['X-REFRESH-EXPIRY-OVERRIDE'] = $this.RefreshTokenExpiration }
        if ($this.AccessTokenExpiration)  { $headers['X-ACCESS-EXPIRY-OVERRIDE']  = $this.AccessTokenExpiration }

        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body '' -TimeoutSec $this.TimeoutSec
        } catch {
            $this.Log("[NCRESTAPI] Authenticate: failed: $($_.Exception.Message)")
            throw "[NCRESTAPI] Authentication failed: $($_.Exception.Message)"
        }
        if (-not $response.tokens.access.token -or -not $response.tokens.refresh.token) {
            throw "[NCRESTAPI] Authenticate: response missing tokens."
        }
        $this.AccessToken  = [NCRestAPI]::ToSecureString($response.tokens.access.token)
        $this.RefreshToken = [NCRestAPI]::ToSecureString($response.tokens.refresh.token)
        $this.Log("[NCRESTAPI] Authenticate: succeeded.")
    }

    [bool] ValidateToken() {
        if (-not $this.AccessToken) { return $false }
        $url = "$($this.BaseUrl)/api/auth/validate"
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $this.AuthHeaders($this.AccessToken) -Method Get -TimeoutSec $this.TimeoutSec
            return $response.message -eq 'The token is valid.'
        } catch {
            $this.Log("[NCRESTAPI] ValidateToken: $($_.Exception.Message)")
            return $false
        }
    }

    [void] RefreshAccessToken() {
        $this.Log("[NCRESTAPI] RefreshAccessToken: starting.")
        if (-not $this.RefreshToken) { throw "[NCRESTAPI] No refresh token available." }
        $url = "$($this.BaseUrl)/api/auth/refresh"
        $refreshPlain = $this.Reveal($this.RefreshToken)
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $refreshPlain"
            'Content-Type'  = 'text/plain'
        }
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $refreshPlain -TimeoutSec $this.TimeoutSec
        } catch {
            $this.Log("[NCRESTAPI] RefreshAccessToken: $($_.Exception.Message). Re-authenticating.")
            $this.Authenticate()
            return
        }
        if (-not $response.tokens.access.token) {
            throw "[NCRESTAPI] RefreshAccessToken: response missing tokens."
        }
        $this.AccessToken  = [NCRestAPI]::ToSecureString($response.tokens.access.token)
        if ($response.tokens.refresh.token) {
            $this.RefreshToken = [NCRestAPI]::ToSecureString($response.tokens.refresh.token)
        }
    }

    [void] EnsureValidToken() {
        if (-not $this.AccessToken) { $this.Authenticate(); return }
        if (-not $this.ValidateToken()) { $this.RefreshAccessToken() }
    }

    hidden [object] Invoke([string]$method, [string]$endpoint, [object]$body) {
        $this.EnsureValidToken()
        $url = "$($this.BaseUrl)/$($endpoint.TrimStart('/'))"
        $headers = $this.AuthHeaders($this.AccessToken)

        $payload = $null
        if ($null -ne $body) {
            if ($body -is [string]) { $payload = $body }
            else { $payload = $body | ConvertTo-Json -Depth 10 }
        }

        $this.Log("[NCRESTAPI] $method $url")

        $attempt = 0
        while ($true) {
            $attempt++
            if ($this.ThrottleMs -gt 0 -and $this.LastRequestAt -ne [datetime]::MinValue) {
                $elapsed = ([datetime]::UtcNow - $this.LastRequestAt).TotalMilliseconds
                $wait = $this.ThrottleMs - $elapsed
                if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]$wait) }
            }
            $this.LastRequestAt = [datetime]::UtcNow
            try {
                $params = @{
                    Uri        = $url
                    Headers    = $headers
                    Method     = $method
                    TimeoutSec = $this.TimeoutSec
                    ErrorAction = 'Stop'
                }
                if ($null -ne $payload) { $params.Body = $payload }
                $response = Invoke-RestMethod @params
                if ($response -and $response.PSObject.Properties['data']) {
                    $totalItems = $null; $itemCount = $null; $pageNumber = $null; $totalPages = $null
                    if ($response.PSObject.Properties['totalItems']) { $totalItems = $response.totalItems }
                    if ($response.PSObject.Properties['itemCount'])  { $itemCount  = $response.itemCount }
                    if ($response.PSObject.Properties['pageNumber']) { $pageNumber = $response.pageNumber }
                    if ($response.PSObject.Properties['totalPages']) { $totalPages = $response.totalPages }
                    if ($null -ne $totalItems) {
                        $this.Log("[NCRESTAPI] page=$pageNumber/$totalPages itemCount=$itemCount totalItems=$totalItems")
                    }
                    if (-not $this.InPager -and $null -ne $totalItems -and $null -ne $itemCount -and $totalItems -gt $itemCount) {
                        Write-Warning "[NCRestAPI] $method $endpoint returned $itemCount of $totalItems items. Pass -All to fetch the rest, or increase -PageSize."
                    }
                    return $response.data
                }
                return $response
            } catch {
                $status = $null
                $response = $_.Exception.Response
                if ($response) { $status = [int]$response.StatusCode }
                $ex = $_.Exception
                # Transport-level failures (connection aborted, socket reset, DNS hiccup,
                # read timeout on an idle connection) don't produce a response object, so we
                # also retry by exception type. Caps at $this.MaxRetries either way.
                $transportRetry = $false
                if (-not $response) {
                    $t = $ex.GetType().FullName
                    if ($t -match 'HttpRequestException|IOException|WebException|SocketException|TaskCanceledException') {
                        $transportRetry = $true
                    }
                }
                $retriable = ($status -eq 429) -or ($status -ge 500 -and $status -lt 600) -or $transportRetry
                if ($retriable -and $attempt -le $this.MaxRetries) {
                    # Honor Retry-After if the server sent one (seconds, or HTTP-date).
                    $delay = [math]::Pow(2, $attempt - 1)
                    if ($response -and $response.Headers) {
                        $ra = $null
                        try { $ra = $response.Headers['Retry-After'] } catch { $ra = $null }
                        if (-not $ra -and $response.Headers.GetEnumerator) {
                            foreach ($h in $response.Headers) {
                                if ($h.Key -eq 'Retry-After') { $ra = $h.Value; break }
                            }
                        }
                        if ($ra) {
                            $raSeconds = 0
                            if ([int]::TryParse($ra, [ref]$raSeconds) -and $raSeconds -gt 0) {
                                # Cap at 60s to avoid pathological server values hanging the caller.
                                $delay = [math]::Min($raSeconds, 60)
                            } else {
                                # HTTP-date is always GMT per RFC 7231; parse as UTC to avoid
                                # local-timezone skew when compared to UtcNow.
                                $raDate = [datetime]::MinValue
                                $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
                                if ([datetime]::TryParse($ra, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$raDate)) {
                                    $diff = ($raDate - [datetime]::UtcNow).TotalSeconds
                                    if ($diff -gt 0) { $delay = [math]::Min($diff, 60) }
                                }
                            }
                        }
                    }
                    $why = if ($transportRetry) { "transport $($ex.GetType().Name)" } else { "HTTP $status" }
                    $this.Log("[NCRESTAPI] $method $($endpoint): $why, retry $attempt/$($this.MaxRetries) after $($delay)s.")
                    Start-Sleep -Seconds $delay
                    continue
                }
                $detail = $_.ErrorDetails.Message
                if (-not $detail) { $detail = $_.Exception.Message }
                $hint = switch ($status) {
                    401     { ' — check ApiToken or rerun Set-NCRestConfig.' }
                    403     { ' — token lacks permission for this endpoint.' }
                    404     { ' — verify BaseUrl and endpoint path.' }
                    default { '' }
                }
                $this.Log("[NCRESTAPI] $method $endpoint failed (HTTP $status): $detail$hint")
                throw "[NCRESTAPI] $method $endpoint failed (HTTP $status): $detail$hint"
            }
        }
        return $null
    }

    [object] Get([string]$endpoint)                          { return $this.Invoke('Get',    $endpoint, $null) }
    [object] Post([string]$endpoint, [object]$body)          { return $this.Invoke('Post',   $endpoint, $body) }
    [object] Put([string]$endpoint, [object]$body)           { return $this.Invoke('Put',    $endpoint, $body) }
    [object] Delete([string]$endpoint)                       { return $this.Invoke('Delete', $endpoint, $null) }
    [object] Delete([string]$endpoint, [object]$body)        { return $this.Invoke('Delete', $endpoint, $body) }
    [object] Patch([string]$endpoint, [object]$body)         { return $this.Invoke('Patch',  $endpoint, $body) }

    [void] Dispose() {
        if ($this.ApiToken)     { $this.ApiToken.Dispose() }
        if ($this.AccessToken)  { $this.AccessToken.Dispose() }
        if ($this.RefreshToken) { $this.RefreshToken.Dispose() }
        $this.ApiToken = $null
        $this.AccessToken = $null
        $this.RefreshToken = $null
        $this.BaseUrl = $null
    }
}

function Add-NCCommonQuery {
    <#
    .SYNOPSIS
    Mutates $Parameters to include the standard filter/select/sort query params.
    Skips sortOrder when it equals the server default ('asc') to keep URLs minimal.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Parameters,
        [int]$FilterId,
        [string]$Select,
        [string]$SortBy,
        [string]$SortOrder
    )
    if ($FilterId)                            { $Parameters['filterId']  = $FilterId }
    if ($Select)                              { $Parameters['select']    = $Select }
    if ($SortBy)                              { $Parameters['sortBy']    = $SortBy }
    if ($SortOrder -and $SortOrder -ne 'asc') { $Parameters['sortOrder'] = $SortOrder }
}

function ConvertTo-NCQueryString {
    [CmdletBinding()]
    param([hashtable]$Parameters)
    if (-not $Parameters -or $Parameters.Count -eq 0) { return '' }
    $pairs = foreach ($kv in $Parameters.GetEnumerator()) {
        # Cast through [string] before the empty-check so integer 0 (which PowerShell
        # coerces to '' in a direct -eq compare) survives as "0".
        $s = [string]$kv.Value
        if ([string]::IsNullOrEmpty($s)) { continue }
        '{0}={1}' -f [uri]::EscapeDataString([string]$kv.Key), [uri]::EscapeDataString($s)
    }
    if (-not $pairs) { return '' }
    return '?' + ($pairs -join '&')
}

function Invoke-NCPagedRequest {
    <#
    .SYNOPSIS
    Iterates an N-central paged GET endpoint until fewer than -PageSize items are returned.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Endpoint,
        [hashtable]$QueryParameters = @{},
        [int]$PageSize = 500
    )
    $api = Get-NCRestApiInstance
    $api.InPager = $true
    try {
        $page = 1
        while ($true) {
            $q = @{}
            foreach ($kv in $QueryParameters.GetEnumerator()) { $q[$kv.Key] = $kv.Value }
            $q['pageNumber'] = $page
            $q['pageSize']   = $PageSize
            $ep = "$Endpoint$(ConvertTo-NCQueryString -Parameters $q)"
            $batch = @($api.Get($ep))
            if ($batch.Count -eq 0) { break }
            $batch
            if ($batch.Count -lt $PageSize) { break }
            $page++
        }
    } finally {
        $api.InPager = $false
    }
}

function Get-NCRestApiInstance {
    [CmdletBinding()]
    param()
    if ($script:NCRestApiInstance) { return $script:NCRestApiInstance }
    if ($global:NCRestApiInstance) { return $global:NCRestApiInstance }
    throw "NCRestAPI instance is not initialized. Run Set-NCRestConfig first."
}
