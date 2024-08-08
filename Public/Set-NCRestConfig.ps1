<#
.SYNOPSIS
This script sets the configuration for the NCREST module.

.DESCRIPTION
The Set-NCRESTConfig.ps1 script is used to configure the settings for the NCREST module. It allows you to specify the base URL, authentication credentials, and other options required for making RESTful API calls using the NCREST module.

.PARAMETER BaseUrl
Specifies the base URL for the RESTful API. This is the URL that will be used as the starting point for all API calls.

.PARAMETER Username
Specifies the username to be used for authentication when making API calls.

.PARAMETER Password
Specifies the password to be used for authentication when making API calls.

.PARAMETER Timeout
Specifies the timeout value (in seconds) for API requests. If no value is provided, the default timeout value will be used.

.EXAMPLE
Set-NCRESTConfig -BaseUrl "https://api.example.com" -Username "admin" -Password "password" -Timeout 30
Configures the NCREST module with the specified base URL, username, password, and timeout value.

.NOTES
This script requires the NCREST module to be installed. You can install it by running the following command:
Install-Module -Name NCREST
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
