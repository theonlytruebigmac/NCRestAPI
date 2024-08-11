<#
.SYNOPSIS
This script sets the configuration for the NCREST module.

.DESCRIPTION
The Set-NCRESTConfig.ps1 script is used to configure the settings for the NCREST module. It allows you to specify the base URL, authentication credentials, and other options required for making RESTful API calls using the NCREST module.

.PARAMETER ServerUrl
Specifies the base URL for the RESTful API. This is the URL that will be used as the starting point for all API calls.

.PARAMETER Username
Specifies the username to be used for authentication when making API calls.

.PARAMETER Password
Specifies the password to be used for authentication when making API calls.

.PARAMETER Timeout
Specifies the timeout value (in seconds) for API requests. If no value is provided, the default timeout value will be used.

.EXAMPLE
Set-NCRESTConfig -ServerUrl "https://api.example.com" -Username "admin" -Password "password" -Timeout 30
Configures the NCREST module with the specified base URL, username, password, and timeout value.

.NOTES
This script requires the NCREST module to be installed. You can install it by running the following command:
Install-Module -Name NCREST
#>

function New-NCRestConnection {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServerUrl,

        [Parameter(Mandatory = $true)]
        [string]$ApiToken,

        [Parameter(Mandatory = $false)]
        [string]$AccessTokenExpiration = "120s",

        [Parameter(Mandatory = $false)]
        [string]$RefreshTokenExpiration = "25h"
    )

    # Validate and correct ServerUrl
    if ($ServerUrl -notmatch '^https://') {
        Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: ServerUrl does not contain 'https://'. Adding 'https://' to the beginning of the URL."
        $ServerUrl = 'https://' + $ServerUrl
    }

    # Remove trailing slash if present
    Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Removing trailing slash from ServerUrl if present."
    $ServerUrl = $ServerUrl.TrimEnd('/')

    # Encrypt tokens manually
    Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Encrypting ApiToken."
    $secureApiToken = ConvertTo-SecureString -String $ApiToken -AsPlainText -Force
    $encryptedApiToken = "Secure:" + [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureApiToken))))

    # Using environment variables for secure storage
    Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Setting environment variables for ServerUrl and encrypted ApiToken."
    [System.Environment]::SetEnvironmentVariable('NcentralServerUrl', $ServerUrl, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('NcentralApiToken', $encryptedApiToken, [System.EnvironmentVariableTarget]::Process)
    
    Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Configuration set: ServerUrl and ApiToken Added"

    if ($AccessTokenExpiration) {
        Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Setting environment variable for AccessTokenExpiration."
        [System.Environment]::SetEnvironmentVariable('AccessTokenExpiration', $AccessTokenExpiration, [System.EnvironmentVariableTarget]::Process)
    } else {
        Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: AccessTokenExpiration must be in the format '120s'."
    }

    if ($RefreshTokenExpiration) {
        Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Setting environment variable for RefreshTokenExpiration."
        [System.Environment]::SetEnvironmentVariable('RefreshTokenExpiration', $RefreshTokenExpiration, [System.EnvironmentVariableTarget]::Process)
    } else {
        Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: RefreshTokenExpiration must be in the format '25h'."
    }

    Write-Verbose "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RestConfig: Creating global NCRestAPI instance."
    $global:NCRestApiInstance = [NCRestAPI]::new($VerbosePreference -eq "Continue")

    return $global:NCRestApiInstance
}
