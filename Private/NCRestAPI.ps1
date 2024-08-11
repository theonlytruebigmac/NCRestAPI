class NCRestAPI {
    [string]$ServerUrl
    [string]$NCVersion
    [string]$AccessTokenExpiration
    [string]$RefreshTokenExpiration
    [string]$ApiToken
    [string]$AccessToken
    [string]$RefreshToken

    hidden [bool]$Verbose

    NCRestAPI([bool]$verbose = $false) {
        $this.ServerUrl = $this.GetEnvVariable('NcentralServerUrl')
        $this.ApiToken = $this.GetEnvVariable('NcentralApiToken')
        $this.AccessToken = $this.GetEnvVariable('NcentralAccessToken')
        $this.RefreshToken = $this.GetEnvVariable('NcentralRefreshToken')
        $this.AccessTokenExpiration = $this.GetEnvVariable('AccessTokenExpiration')
        $this.RefreshTokenExpiration = $this.GetEnvVariable('RefreshTokenExpiration')
        $this.Verbose = $verbose
        $this.NCVersion = $null
    
        $this.WriteVerboseOutput("Initializing: Decrypting Stored API Token from Config.")
        $this.DecryptTokens()
    
        if (-not $this.AccessToken -or -not $this.RefreshToken) {
            $this.WriteVerboseOutput("Initializing: Authenticating for the first time.")
            $this.Authenticate()

            if ($this.AccessToken -and $this.RefreshToken) {
                $this.WriteVerboseOutput("Initializing: Getting NC Version.")
                $this.GetNCVersion()
            }
        }
    }

    [string] GetEnvVariable([string]$name) {
        return [System.Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::Process)
    }

    [void] WriteVerboseOutput([string]$message) {
        $maskedMessage = $message -replace '(Bearer\s+\w+\.[\w-]+\.[\w-]+)', 'Bearer [MASKED]' `
            -replace '(token"\s*:\s*"\w+\.[\w-]+\.[\w-]+)', 'token": "[MASKED]' `
            -replace '(token":\s*"\w+\.[\w-]+\.[\w-]+)', 'token": "[MASKED]'
        if ($this.Verbose) {
            Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $maskedMessage"
        }
    }

    hidden [string] GetNCVersion() {
        if (-not $this.NCVersion) {
            $this.WriteVerboseOutput("GetNCVersion: Getting N-central Version.")
            $versionInfo = ($this.NCRestRequest("GET", "/api/server-info/extra", $null)._extra | Select-Object -ExpandProperty "Installation: UI Product Version").tostring()
            
            if ($versionInfo) {
                $this.NCVersion = $versionInfo
                $this.WriteVerboseOutput("GetNCVersion: NCVersion updated to: $($this.NCVersion)")
            }
            else {
                $this.WriteVerboseOutput("GetNCVersion: Failed to retrieve NCVersion.")
            }
        }
    
        return $this.NCVersion
    }    

    [void] StoreTokens([string]$accessToken, [string]$refreshToken) {
        $this.WriteVerboseOutput("StoreTokens: Storing access and refresh tokens.")
        $this.AccessToken = $this.EncryptToken($accessToken)
        $this.RefreshToken = $this.EncryptToken($refreshToken)

        $this.WriteVerboseOutput("StoreTokens: Setting environment variables for encrypted access and refresh tokens.")
        [System.Environment]::SetEnvironmentVariable('NcentralAccessToken', $this.AccessToken, [System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('NcentralRefreshToken', $this.RefreshToken, [System.EnvironmentVariableTarget]::Process)
    }

    [string] EncryptToken([string]$token) {
        if ($token -notmatch '^Secure:') {
            $secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
            return "Secure:" + [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))))
        }
        return $token
    }

    [string] DecryptToken([string]$encryptedToken) {
        if ($encryptedToken -match '^Secure:') {
            $encryptedToken = $encryptedToken.Substring(7)
            return [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encryptedToken))
        }
        return $encryptedToken
    }

    [void] DecryptTokens() {
        $this.ApiToken = $this.DecryptToken($this.ApiToken)
        $this.AccessToken = $this.DecryptToken($this.AccessToken)
        $this.RefreshToken = $this.DecryptToken($this.RefreshToken)
    }

    [void] EncryptTokens() {
        $this.ApiToken = $this.EncryptToken($this.ApiToken)
        $this.AccessToken = $this.EncryptToken($this.AccessToken)
        $this.RefreshToken = $this.EncryptToken($this.RefreshToken)
    }

    [void] Authenticate() {
        $this.WriteVerboseOutput("Authenticate: Starting authentication process.")
        $url = "$($this.ServerUrl)/api/auth/authenticate"
        
        $this.DecryptTokens()

        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.ApiToken)"
        }

        if ($this.RefreshTokenExpiration -and $this.AccessTokenExpiration) {
            $headers['X-REFRESH-EXPIRY-OVERRIDE'] = "$($this.RefreshTokenExpiration)"
            $headers['X-ACCESS-EXPIRY-OVERRIDE'] = "$($this.AccessTokenExpiration)"
            $this.WriteVerboseOutput("Authenticate: Refresh and Access Token expiration set. Access token: $($this.AccessTokenExpiration), Refresh token: $($this.RefreshTokenExpiration)")
        }
        elseif ($this.RefreshTokenExpiration) {
            $headers['X-REFRESH-EXPIRY-OVERRIDE'] = "$($this.RefreshTokenExpiration)"
            $this.WriteVerboseOutput("Authenticate: Refresh Token expiration set. Refresh token: $($this.RefreshTokenExpiration)")
        }
        elseif ($this.AccessTokenExpiration) {
            $headers['X-ACCESS-EXPIRY-OVERRIDE'] = "$($this.AccessTokenExpiration)"
            $this.WriteVerboseOutput("Authenticate: Access Token expiration set. Access token: $($this.AccessTokenExpiration)")
        }
    
        $this.WriteVerboseOutput("Authenticate: URL: $($url)")
        $this.WriteVerboseOutput("Authenticate: Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body ''
            $this.WriteVerboseOutput("Authenticate: Response: $($response | ConvertTo-Json -Depth 5)")
            if ($response.tokens -and $response.tokens.access.token) {
                $this.StoreTokens($response.tokens.access.token, $response.tokens.refresh.token)
                $this.EncryptTokens()
            }
            else {
                throw "Authenticate: Authentication response did not contain an access token."
            }
        }
        catch {
            $this.WriteVerboseOutput("Authenticate: Authentication failed: $($_.Exception.Message)")
            throw $_.Exception.Message
        }
    }    

    [bool] ValidateToken() {
        $this.WriteVerboseOutput(" ValidateToken: Starting Token Validation process.")
        $this.DecryptTokens()
    
        $url = "$($this.ServerUrl)/api/auth/validate"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
        }
        $this.WriteVerboseOutput(" ValidateToken: Making GET request to URL: $url with Headers: $($headers | ConvertTo-Json)")
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            $this.EncryptTokens()
            $this.WriteVerboseOutput(" ValidateToken: Validation response: $($response.message)")
            if ($response.message -ne "The token is valid.") {
                throw " ValidateToken: Token validation failed: $($response.message)"
            }
            return $true
        }
        catch {
            $this.WriteVerboseOutput(" ValidateToken: Token validation failed: $($_.Exception.Message)")
            return $false
        }
    }

    [void] EnsureValidToken() {
        $this.WriteVerboseOutput(" EnsureValidToken: Checking if Access Token is still valid.")
        
        $this.DecryptTokens()
        
        if (-not $this.AccessToken) {
            throw " EnsureValidToken: No access token. Authentication failed."
        }
    
        if (-not $this.ValidateToken()) {
            $this.WriteVerboseOutput(" EnsureValidToken: Token validation failed. Refreshing token.")
            $this.RefreshAccessToken()
            $this.EncryptTokens()
        }
    
        if (-not $this.AccessToken) {
            throw " EnsureValidToken: No access token. Refresh failed."
        }
    }    

    [PSCustomObject] NCRestRequest([string]$method, [string]$endpoint, [PSCustomObject]$body = $null) {
        $this.WriteVerboseOutput(" NCRestRequest: Preparing to make $method request to $endpoint.")
        $this.EnsureValidToken()
    
        $this.DecryptTokens()
    
        $url = "$($this.ServerUrl)$endpoint"
        $headers = @{
            'Accept'        = '*/*'
            'Authorization' = "Bearer $($this.AccessToken)"
            'Content-Type'  = 'application/json'
        }
    
        $this.WriteVerboseOutput(" NCRestRequest: URL: $url")
        $this.WriteVerboseOutput(" NCRestRequest: Headers: $($headers | ConvertTo-Json)")
    
        if ($body -and $method -in @("POST", "PUT")) {
            $this.WriteVerboseOutput(" NCRestRequest: Body: $($body | ConvertTo-Json -Depth 5)")
        }
    
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method $method -Body ($body | ConvertTo-Json -Depth 5)
            $this.EncryptTokens()
            $this.WriteVerboseOutput(" NCRestRequest: Response received: $($response | ConvertTo-Json -Depth 5)")
    
            if ($response.PSObject.Properties["data"]) {
                return $response.data
            }
            else {
                return $response
            }
        }
        catch {
            $this.WriteVerboseOutput(" NCRestRequest: $method request failed: $($_.Exception.Message)")
            return $null
        }
    }
    
}