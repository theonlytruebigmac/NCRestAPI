<#
.SYNOPSIS
Creates a new user in the specified organization unit.

.DESCRIPTION
POST /api/org-units/{orgUnitId}/users with the UserCreateRequest schema.

.PARAMETER OrgUnitId
Org unit to create the user in.

.PARAMETER Email
User email address (required).

.PARAMETER Password
User password (required). Accepts [securestring] or [string].

.PARAMETER FirstName
User first name (required).

.PARAMETER LastName
User last name (required).

.PARAMETER Username
Optional username (defaults to email if omitted by the API).

.PARAMETER Country
Optional country.

.PARAMETER PostalCode
Optional postal code.

.PARAMETER Street1
Optional primary street address.

.PARAMETER Street2
Optional secondary street address.

.PARAMETER City
Optional city.

.PARAMETER State
Optional state.

.PARAMETER Telephone
Optional telephone number.

.PARAMETER Ext
Optional phone extension.

.PARAMETER Department
Optional department.

.PARAMETER NotificationEmail
Optional notification email.

.PARAMETER Status
Optional user status.

.PARAMETER RoleIds
Optional array of role IDs to assign.

.PARAMETER AccessGroupIds
Optional array of access group IDs to assign.

.PARAMETER ApiOnlyUser
If set, creates an API-only user.

.EXAMPLE
New-NCUser -OrgUnitId 1 -Email 'user@example.com' -Password (Read-Host -AsSecureString) `
    -FirstName 'Jane' -LastName 'Doe'
#>
function New-NCUser {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Email,

        [Parameter(Mandatory)]
        [object]$Password,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FirstName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LastName,

        [string]$Username,
        [string]$Country,
        [string]$PostalCode,
        [string]$Street1,
        [string]$Street2,
        [string]$City,
        [string]$State,
        [string]$Telephone,
        [string]$Ext,
        [string]$Department,
        [string]$NotificationEmail,
        [string]$Status,
        [object[]]$RoleIds,
        [object[]]$AccessGroupIds,
        [switch]$ApiOnlyUser
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] New-NCUser: POST api/org-units/$OrgUnitId/users"

        $plainPassword = if ($Password -is [securestring]) {
            $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
            try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
            finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
        } else { [string]$Password }

        $body = [ordered]@{
            email     = $Email
            password  = $plainPassword
            firstName = $FirstName
            lastName  = $LastName
        }

        if ($Username)          { $body.username          = $Username }
        if ($Country)           { $body.country           = $Country }
        if ($PostalCode)        { $body.postalCode        = $PostalCode }
        if ($Street1)           { $body.street1           = $Street1 }
        if ($Street2)           { $body.street2           = $Street2 }
        if ($City)              { $body.city              = $City }
        if ($State)             { $body.state             = $State }
        if ($Telephone)         { $body.telephone         = $Telephone }
        if ($Ext)               { $body.ext               = $Ext }
        if ($Department)        { $body.department        = $Department }
        if ($NotificationEmail) { $body.notificationEmail = $NotificationEmail }
        if ($Status)            { $body.status            = $Status }
        if ($RoleIds)           { $body.roleIds           = $RoleIds }
        if ($AccessGroupIds)    { $body.accessGroupIds    = $AccessGroupIds }
        if ($ApiOnlyUser)       { $body.apiOnlyUser       = $true }

        if (-not $PSCmdlet.ShouldProcess($Email, 'Create user')) { return }
        $api.Post("api/org-units/$OrgUnitId/users", $body)
    }
}
