<#
.SYNOPSIS
Retrieves various types of information from the N-central API.

.DESCRIPTION
The `Get-NCServerInfo` function retrieves various types of information from the N-central API.
It can retrieve general API information, health status, or extra server information based on the provided parameters.

.PARAMETER health
Retrieves the health status of the N-central API.

.PARAMETER extra
Retrieves extra server information from the N-central API.

.EXAMPLE
PS C:\> Get-NCServerInfo -health -Verbose
Retrieves the health status of the N-central API with verbose output enabled.

.EXAMPLE
PS C:\> Get-NCServerInfo -extra
Retrieves extra server information from the N-central API.

.EXAMPLE
PS C:\> Get-NCServerInfo
Retrieves general API information from the N-central API.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns information from the specified N-central API endpoint.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function Get-NCServerInfo {
    [CmdletBinding()]
    param (
        [switch]$health,

        [switch]$extra
    )
    
    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    Write-Verbose "[FUNCTION] Running Get-NCServerInfo."
    
    if ($health) {
        Write-Verbose "[FUNCTION] Retrieving health status."
        $endpoint = "api/health"
    }
    elseif ($extra) {
        Write-Verbose "[FUNCTION] Retrieving extra server information."
        $endpoint = "api/server-info/extra"
    }
    else {
        Write-Verbose "[FUNCTION] Retrieving general API information."
        $endpoint = "api"
    }

    try {
        $data = $api.Get($endpoint)

        if ($extra) {
            Write-Verbose "[FUNCTION] Returning extra server information."
            return $data._extra
        }
        elseif ($health) {
            Write-Verbose "[FUNCTION] Returning health status."
            return $data
        }
        else {
            Write-Verbose "[FUNCTION] Returning general API information."
            return $data._links
        }
    }
    catch {
        Write-Error "Error retrieving rest information: $_"
    }
}