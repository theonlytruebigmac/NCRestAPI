<#
.SYNOPSIS
Retrieves N-central API service metadata.

.DESCRIPTION
Covers four of the `/api` metadata endpoints:

  - default  -> GET /api              - link list of top-level endpoints
  - -Version -> GET /api/server-info  - running API-Service version
  - -Health  -> GET /api/health       - health status
  - -Extra   -> GET /api/server-info/extra - extra version info (public)

Supply `-Credential` together with `-Extra` to use the authenticated variant at
POST /api/server-info/extra/authenticated, which returns richer, per-user version
information.

.EXAMPLE
Get-NCServerInfo

.EXAMPLE
Get-NCServerInfo -Version

.EXAMPLE
Get-NCServerInfo -Extra -Credential (Get-Credential)
#>
function Get-NCServerInfo {
    [CmdletBinding(DefaultParameterSetName = 'Links')]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Parameters are discriminators consumed via ParameterSetName.')]
    param (
        [Parameter(ParameterSetName = 'Health')][switch]$Health,
        [Parameter(ParameterSetName = 'Version')][switch]$Version,
        [Parameter(ParameterSetName = 'Extra')][switch]$Extra,
        [Parameter(ParameterSetName = 'Extra')][pscredential]$Credential
    )

    Write-Verbose "[FUNCTION] Get-NCServerInfo: invoked."
    $api = Get-NCRestApiInstance

    switch ($PSCmdlet.ParameterSetName) {
        'Health'  { return $api.Get('api/health') }
        'Version' { return $api.Get('api/server-info') }
        'Extra'   {
            if ($Credential) {
                $body = @{
                    username = $Credential.UserName
                    password = $Credential.GetNetworkCredential().Password
                }
                return $api.Post('api/server-info/extra/authenticated', $body)
            }
            return $api.Get('api/server-info/extra')
        }
        default   { return $api.Get('api') }
    }
}
