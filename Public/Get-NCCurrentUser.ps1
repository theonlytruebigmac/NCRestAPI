<#
.SYNOPSIS
Retrieves the current authenticated user's information.

.DESCRIPTION
GET /api/users/me.

.EXAMPLE
Get-NCCurrentUser
#>
function Get-NCCurrentUser {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param ()

    Write-Verbose "[FUNCTION] Get-NCCurrentUser: api/users/me"
    $api = Get-NCRestApiInstance
    $api.Get('api/users/me')
}
