<#
.SYNOPSIS
Updates customer limits for an organization unit.

.DESCRIPTION
PATCH /api/org-units/{orgUnitId}/limits. Only bound parameters are sent.

.PARAMETER OrgUnitId
Organization unit ID.

.PARAMETER Limits
Hashtable of limit key/value pairs to update. Keys and structure depend on the
N-central server version.

.EXAMPLE
Set-NCOrgLimits -OrgUnitId 123 -Limits @{ maxDevices = 500 }
#>
function Set-NCOrgLimits {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory)]
        [hashtable]$Limits
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        Write-Verbose "[FUNCTION] Set-NCOrgLimits: PATCH api/org-units/$OrgUnitId/limits"
        if (-not $PSCmdlet.ShouldProcess($OrgUnitId, 'Update org unit limits')) { return }
        $api.Patch("api/org-units/$OrgUnitId/limits", $Limits)
    }
}
