<#
.SYNOPSIS
Retrieves customer limits for an organization unit.

.DESCRIPTION
GET /api/org-units/{orgUnitId}/limits.

.PARAMETER OrgUnitId
Organization unit ID.

.EXAMPLE
Get-NCOrgLimits -OrgUnitId 123
#>
function Get-NCOrgLimits {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]$OrgUnitId
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Get-NCOrgLimits: api/org-units/$OrgUnitId/limits"
        $api.Get("api/org-units/$OrgUnitId/limits")
    }
}
