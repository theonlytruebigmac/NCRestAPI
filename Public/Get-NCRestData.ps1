<#
.SYNOPSIS
Retrieves data from a specified N-central API endpoint.

.DESCRIPTION
The `Get-NCRestData` function retrieves data from a specified N-central API endpoint.
It requires the endpoint URL to be provided.

.PARAMETER Endpoint
The endpoint URL from which to retrieve data. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-NCRestData -Endpoint "api/customers" -Verbose
Retrieves data from the "api/customers" endpoint with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCRestData -Endpoint "api/devices"
Retrieves data from the "api/devices" endpoint.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns data from the specified N-central API endpoint.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCRestData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Endpoint
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    Write-Verbose "[FUNCTION] Running Get-NCRestData."
    
    try {
        Write-Verbose "[FUNCTION] Retrieving data from endpoint: $endpoint."
        $data = $api.Get($endpoint)
        return $data
    }
    catch {
        Write-Error "Error retrieving endpoint response: $_"
    }
}
