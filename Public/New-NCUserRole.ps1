<#
.SYNOPSIS
Creates a new user role under an organization unit.

.DESCRIPTION
POST /api/org-units/{orgUnitId}/user-roles with the `CreateUserRoleRequest` schema.

.PARAMETER OrgUnitId
Org unit that owns the role.

.PARAMETER RoleName
Role name.

.PARAMETER Description
Role description.

.PARAMETER PermissionIds
Array of permission IDs to grant.

.PARAMETER UserIds
Optional initial user assignment.

.EXAMPLE
New-NCUserRole -OrgUnitId 1 -RoleName 'ReadOnly' -Description 'Read only access' -PermissionIds 'VIEW_DEVICE','VIEW_CUSTOMER'
#>
function New-NCUserRole {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RoleName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory)]
        [object[]]$PermissionIds,

        [object[]]$UserIds
    )
    begin { $api = Get-NCRestApiInstance }
    process {
        $body = [ordered]@{
            roleName      = $RoleName
            description   = $Description
            permissionIds = $PermissionIds
        }
        if ($UserIds) { $body.userIds = $UserIds }

        if (-not $PSCmdlet.ShouldProcess($RoleName, 'Create user role')) { return }
        $api.Post("api/org-units/$OrgUnitId/user-roles", $body)
    }
}
