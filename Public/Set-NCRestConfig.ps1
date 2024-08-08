<#
.SYNOPSIS
Sets the configuration for the NCRestAPI module.

.DESCRIPTION
The Set-NCRestConfig function is used to set the configuration for the NCRestAPI module. It takes the following parameters:
- BaseUrl: The base URL of the N-central server.
- ApiToken: The API token for authentication.
- AccessTokenExpiration: (Optional) The expiration time for the access token. Default value is "1h".
- RefreshTokenExpiration: (Optional) The expiration time for the refresh token. Default value is "25h".

.PARAMETER BaseUrl
The base URL of the N-central server. It should start with "https://".

.PARAMETER ApiToken
The API token for authentication.

.PARAMETER AccessTokenExpiration
(Optional) The expiration time for the access token. It should be in the format "120s" for seconds, "30m" for minutes, or "2h" for hours. Default value is "1h".

.PARAMETER RefreshTokenExpiration
(Optional) The expiration time for the refresh token. It should be in the format "24h" for hours or "7d" for days. Default value is "25h".

.EXAMPLE
Set-NCRestConfig -BaseUrl "https://ncentral.example.com" -ApiToken "1234567890" -AccessTokenExpiration "2h" -RefreshTokenExpiration "24h"
Sets the configuration with the specified parameters.

.EXAMPLE
Set-NCRestConfig -BaseUrl "ncentral.example.com" -ApiToken "1234567890"
Sets the configuration with the default expiration times.
#>

function Set-NCRestConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,

        [Parameter(Mandatory = $true)]
        [string]$ApiToken,

        [Parameter(Mandatory = $false)]
        [string]$AccessTokenExpiration = "1h",
       
        [Parameter(Mandatory = $false)]
        [string]$RefreshTokenExpiration = "25h"
    )

    # Validate and correct BaseUrl
    if ($BaseUrl -notmatch '^https://') {
        Write-Verbose "[NCRESTCONFIG] BaseUrl does not contain 'https://'. Adding 'https://' to the beginning of the URL."
        $BaseUrl = 'https://' + $BaseUrl
    }

    # Remove trailing slash if present
    Write-Verbose "[NCRESTCONFIG] Removing trailing slash from BaseUrl if present."
    $BaseUrl = $BaseUrl.TrimEnd('/')

    # Encrypt tokens manually
    $secureApiToken = ConvertTo-SecureString -String $ApiToken -AsPlainText -Force
    $encryptedApiToken = "Secure:" + [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureApiToken))))

    # Using environment variables for secure storage
    Write-Verbose "[NCRESTCONFIG] Setting environment variables for BaseUrl and ApiToken."

    [System.Environment]::SetEnvironmentVariable('NcentralBaseUrl', $BaseUrl, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('NcentralApiToken', $encryptedApiToken, [System.EnvironmentVariableTarget]::Process)
    
    Write-Verbose "[NCRESTCONFIG] Configuration set: BaseUrl and ApiToken Added"

    if ($AccessTokenExpiration) {
        Write-Verbose "[NCRESTCONFIG] Setting environment variable for AccessTokenExpiration."
        [System.Environment]::SetEnvironmentVariable('AccessTokenExpiration', $AccessTokenExpiration, [System.EnvironmentVariableTarget]::Process)
    } else {
        Write-Warning "[NCRESTCONFIG] AccessTokenExpiration must be in the format '120s'."
    }

    if ($RefreshTokenExpiration) {
        Write-Verbose "[NCRESTCONFIG] Setting environment variable for RefreshTokenExpiration."
        [System.Environment]::SetEnvironmentVariable('RefreshTokenExpiration', $RefreshTokenExpiration, [System.EnvironmentVariableTarget]::Process)
    } else {
        Write-Warning "[NCRESTCONFIG] RefreshTokenExpiration must be in the format '25h'."
    }

    Write-Verbose "[NCRESTCONFIG] Creating global NCRestAPI instance."
    $global:NCRestApiInstance = [NCRestAPI]::new($VerbosePreference -eq "Continue")
}