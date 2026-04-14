<#
.SYNOPSIS
Returns a snapshot of the active NCRestAPI instance's configuration, or disposes it.

.PARAMETER Kill
Dispose the cached instance and clear module/global references. Subsequent calls will require
Set-NCRestConfig or Connect-NCentral to re-establish the connection.

.EXAMPLE
Get-NCRestApiInfo

.EXAMPLE
Get-NCRestApiInfo -Kill
#>
function Get-NCRestApiInfo {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [switch]$Kill
    )

    $api = Get-NCRestApiInstance

    if ($Kill) {
        $api.Dispose()
        $script:NCRestApiInstance = $null
        $global:NCRestApiInstance = $null
        Write-Verbose "NCRestAPI instance disposed."
        return
    }

    [pscustomobject]@{
        BaseUrl                = $api.BaseUrl
        AccessTokenExpiration  = $api.AccessTokenExpiration
        RefreshTokenExpiration = $api.RefreshTokenExpiration
        HasAccessToken         = [bool]$api.AccessToken
        HasRefreshToken        = [bool]$api.RefreshToken
        TimeoutSec             = $api.TimeoutSec
        MaxRetries             = $api.MaxRetries
        ThrottleMs             = $api.ThrottleMs
    }
}
