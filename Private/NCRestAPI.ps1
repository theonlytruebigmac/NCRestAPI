<#Requires -Version 7.4.4

<#
.SYNOPSIS
NCRestAPI class to interact with the N-central API, handling authentication, token management, and HTTP requests.

.DESCRIPTION
The `NCRestAPI` class provides methods to interact with the N-central API. It handles authentication, token validation, token refresh, and provides methods for making GET, POST, PUT, and DELETE requests. 
The class uses environment variables to securely store the base URL and API tokens.

.PARAMETER verbose
Enables verbose logging if set to $true. Default is $false.

.INPUTS
[void] WriteVerboseOutput([string]$message)
Writes masked verbose output if verbose logging is enabled.

[void] StoreTokens([string]$accessToken, [string]$refreshToken)
Stores access and refresh tokens in environment variables.

[void] Authenticate()
Authenticates and obtains access and refresh tokens.

[bool] ValidateToken()
Validates the current access token.

[void] RefreshAccessToken()
Refreshes the access token using the refresh token.

[void] EnsureValidToken()
Ensures a valid access token is available, refreshing it if necessary.

[PSCustomObject] Get([string]$endpoint)
Makes a GET request to the specified endpoint.

[PSCustomObject] Post([string]$endpoint, [PSCustomObject]$body)
Makes a POST request to the specified endpoint with the given body.

[PSCustomObject] Put([string]$endpoint, [string]$body)
Makes a PUT request to the specified endpoint with the given body.

[PSCustomObject] Delete([string]$endpoint)
Makes a DELETE request to the specified endpoint.

.EXAMPLE
# Instantiate the NCRestAPI class with verbose logging
$api = [NCRestAPI]::new($true)

# Make a GET request
$response = $api.Get("your/endpoint")

# Make a POST request
$body = [PSCustomObject]@{ key = "value" }
$response = $api.Post("your/endpoint", $body)

# Make a PUT request
$body = "{ 'key': 'value' }"
$response = $api.Put("your/endpoint", $body)

# Make a DELETE request
$response = $api.Delete("your/endpoint")

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

class NCRestAPI {
    [string]$BaseUrl
    [string]$ApiToken
    [string]$AccessToken
    [string]$RefreshToken
    [string]$AccessTokenExpiration
    [string]$RefreshTokenExpiration
    [bool]$Verbose

    NCRestAPI([bool]$verbose = $false) {
        $this.BaseUrl = [System.Environment]::GetEnvironmentVariable('NcentralBaseUrl', [System.EnvironmentVariableTarget]::Process)
        $this.ApiToken = [System.Environment]::GetEnvironmentVariable('NcentralApiToken', [System.EnvironmentVariableTarget]::Process)
        $this.AccessToken = [System.Environment]::GetEnvironmentVariable('NcentralAccessToken', [System.EnvironmentVariableTarget]::Process)
        $this.RefreshToken = [System.Environment]::GetEnvironmentVariable('NcentralRefreshToken', [System.EnvironmentVariableTarget]::Process)
        $this.AccessTokenExpiration = [System.Environment]::GetEnvironmentVariable('AccessTokenExpiration', [System.EnvironmentVariableTarget]::Process)
        $this.RefreshTokenExpiration = [System.Environment]::GetEnvironmentVariable('RefreshTokenExpiration', [System.EnvironmentVariableTarget]::Process)
        $this.Verbose = $verbose
        if (-not $this.AccessToken -or -not $this.RefreshToken) {
            $this.Authenticate()
        }
    }

    [void] WriteVerboseOutput([string]$message) {
        $maskedMessage = $message -replace '(Bearer\s+\w+\.[\w-]+\.[\w-]+)', 'Bearer [MASKED]' `
            -replace '(token"\s*:\s*"\w+\.[\w-]+\.[\w-]+)', 'token": "[MASKED]' `
            -replace '(token":\s*"\w+\.[\w-]+\.[\w-]+)', 'token": "[MASKED]'
        if ($this.Verbose) {
            Write-Verbose $maskedMessage
        }
    }

    [void] StoreTokens([string]$accessToken, [string]$refreshToken) {
        $this.WriteVerboseOutput("[NCRESTAPI] StoreTokens: Storing access and refresh tokens.")
        [System.Environment]::SetEnvironmentVariable('NcentralAccessToken', $accessToken, [System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('NcentralRefreshToken', $refreshToken, [System.EnvironmentVariableTarget]::Process)
        $this.AccessToken = $accessToken
        $this.RefreshToken = $refreshToken
    }

    [void] Authenticate() {
        $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Starting authentication process.")
        $url = "$($this.BaseUrl)/api/auth/authenticate"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.ApiToken)"
        }

        if ($this.RefreshTokenExpiration -and $this.AccessTokenExpiration) {
            $headers['X-REFRESH-EXPIRY-OVERRIDE'] = "$($this.RefreshTokenExpiration)"
            $headers['X-ACCESS-EXPIRY-OVERRIDE']  = "$($this.AccessTokenExpiration)"
            $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Refresh and Access Token expiration set. Access token: $($this.AccessTokenExpiration), Refresh token: $($this.RefreshTokenExpiration)")
        } elseif ($this.RefreshTokenExpiration) {
            $headers['X-REFRESH-EXPIRY-OVERRIDE'] = "$($this.RefreshTokenExpiration)"
            $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Refresh Token expiration set. Refresh token: $($this.RefreshTokenExpiration)")
        } elseif ($this.AccessTokenExpiration) {
            $headers['X-ACCESS-EXPIRY-OVERRIDE']  = "$($this.AccessTokenExpiration)"
            $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Access Token expiration set. Access token: $($this.AccessTokenExpiration)")
        }

        $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: URL: $($url)")
        $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body ''
            $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Response: $($response | ConvertTo-Json -Depth 5)")
            if ($response.tokens -and $response.tokens.access.token) {
                $this.StoreTokens($response.tokens.access.token, $response.tokens.refresh.token)
            }
            else {
                throw "[NCRESTAPI] Authenticate: Authentication response did not contain an access token."
            }
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] Authenticate: Authentication failed: $($_.Exception.Message)")
            throw $_.Exception.Message
        }
    }

    [bool] ValidateToken() {
        $this.WriteVerboseOutput("[NCRESTAPI] ValidateToken: Starting Token Validation process.")
        $url = "$($this.BaseUrl)/api/auth/validate"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
        }
        $this.WriteVerboseOutput("[NCRESTAPI] ValidateToken: Making GET request to URL: $url with Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            $this.WriteVerboseOutput("[NCRESTAPI] ValidateToken: Validation response: $($response.message)")
            if ($response.message -ne "The token is valid.") {
                throw "[NCRESTAPI] ValidateToken: Token validation failed: $($response.message)"
            }
            return $true
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] ValidateToken: Token validation failed: $($_.Exception.Message)")
            return $false
        }
    }

    [void] RefreshAccessToken() {
        $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Starting token refresh process.")
        $url = "$($this.BaseUrl)/api/auth/refresh"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.RefreshToken)"
            'Content-Type'  = 'text/plain'
        }
        $body = $this.RefreshToken
        $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: URL: $url")
        $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Headers: $($headers | ConvertTo-Json)")
        $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Body: [MASKED]")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body
            $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Refresh Response: $($response | ConvertTo-Json -Depth 5)")
            if ($response.tokens -and $response.tokens.access.token) {
                $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Access token refreshed.")
                $this.StoreTokens($response.tokens.access.token, $response.tokens.refresh.token)
            }
            else {
                throw "[NCRESTAPI] RefreshAccessToken: Refresh response did not contain an access token."
            }
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] RefreshAccessToken: Token refresh failed: $($_.Exception.Message)")
            throw $_.Exception.Message
        }
    }

    [void] EnsureValidToken() {
        $this.WriteVerboseOutput("[NCRESTAPI] EnsureValidToken: Checking if Access Token is still valid.")
        if (-not $this.AccessToken) {
            throw "[NCRESTAPI] EnsureValidToken: No access token. Authentication failed."
        }

        if (-not $this.ValidateToken()) {
            $this.WriteVerboseOutput("[NCRESTAPI] EnsureValidToken: Token validation failed. Refreshing token.")
            $this.RefreshAccessToken()
        }

        if (-not $this.AccessToken) {
            throw "[NCRESTAPI] EnsureValidToken: No access token. Refresh failed."
        }
    }

    [PSCustomObject] Get([string]$endpoint) {
        $this.WriteVerboseOutput("[NCRESTAPI] GET: Preparing to make GET request to $endpoint.")
        $this.WriteVerboseOutput("[NCRESTAPI] GET: Ensuring current tokens are valid.")
        $this.EnsureValidToken()
        $url = "$($this.BaseUrl)/$endpoint"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
            'Content-Type'  = 'application/json'
        }
        $this.WriteVerboseOutput("[NCRESTAPI] GET: URL: $url")
        $this.WriteVerboseOutput("[NCRESTAPI] GET: Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            $this.WriteVerboseOutput("[NCRESTAPI] GET: Response received: $($response | ConvertTo-Json -Depth 5)")
            if ($response.PSObject.Properties["data"]) {
                return $response.data
            }
            else {
                return $response
            }
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] GET: request failed: $($_.Exception.Message)")
            return $null
        }
    }

    [PSCustomObject] Post([string]$endpoint, [PSCustomObject]$body) {
        $this.WriteVerboseOutput("[NCRESTAPI] POST: Preparing to make POST request to $endpoint.")
        $this.WriteVerboseOutput("[NCRESTAPI] POST: Ensuring current tokens are valid.")
        $this.EnsureValidToken()
        $url = "$($this.BaseUrl)/$endpoint"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
            'Content-Type'  = 'application/json'
        }
        $this.WriteVerboseOutput("[NCRESTAPI] POST: URL: $url")
        $this.WriteVerboseOutput("[NCRESTAPI] POST: Headers: $($headers | ConvertTo-Json)")
        $this.WriteVerboseOutput("[NCRESTAPI] POST: Body: $($body | ConvertTo-Json -Depth 5)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 5)
            $this.WriteVerboseOutput("[NCRESTAPI] POST: Response received: $($response | ConvertTo-Json -Depth 5)")
            return $response
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] POST: request failed: $($_.Exception.Message)")
            return $null
        }
    }

    [PSCustomObject] Put([string]$endpoint, [string]$body) {
        $this.WriteVerboseOutput("[NCRESTAPI] PUT: Preparing to make PUT request to $endpoint.")
        $this.writeverboseoutput("[NCRESTAPI] PUT: Ensuring current tokens are valid.")
        $this.EnsureValidToken()
        $url = "$($this.BaseUrl)/$endpoint"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
            'Content-Type'  = 'application/json'
        }
        $this.WriteVerboseOutput("[NCRESTAPI] PUT: URL: $url")
        $this.WriteVerboseOutput("[NCRESTAPI] PUT: Headers: $($headers | ConvertTo-Json)")
        $this.WriteVerboseOutput("[NCRESTAPI] PUT: Body: $body")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body $body
            $this.WriteVerboseOutput("[NCRESTAPI] PUT: Response received: $($response | ConvertTo-Json -Depth 5)")
            return $response
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] PUT: request failed: $($_.Exception.Message)")
            return $null
        }
    }

    [PSCustomObject] Delete([string]$endpoint) {
        $this.WriteVerboseOutput("[NCRESTAPI] DELETE: Preparing to make DELETE request to $endpoint.")
        $this.WriteVerboseOutput("[NCRESTAPI] DELETE: Ensuring current tokens are valid.")
        $this.EnsureValidToken()
        $url = "$($this.BaseUrl)/$endpoint"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
            'Content-Type'  = 'application/json'
        }
        $this.WriteVerboseOutput("[NCRESTAPI] DELETE: URL: $url")
        $this.WriteVerboseOutput("[NCRESTAPI] DELETE: Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Delete
            $this.WriteVerboseOutput("[NCRESTAPI] DELETE: Response received: $($response | ConvertTo-Json -Depth 5)")
            return $response
        }
        catch {
            $this.WriteVerboseOutput("[NCRESTAPI] DELETE: request failed: $($_.Exception.Message)")
            return $null
        }
    }
}