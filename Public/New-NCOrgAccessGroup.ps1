<#
.SYNOPSIS
Creates a new organization access group in the N-central API.

.DESCRIPTION
The `New-NCOrgAccessGroup` function creates a new organization access group in the N-central API.
It requires parameters to specify the organization unit ID, group name, and group description.
Optional parameters include arrays of organization unit IDs and user IDs to be associated with the group, as well as an option to auto-include new organization units.

.PARAMETER OrgUnitId
The organization unit ID under which the access group will be created. This parameter is mandatory.

.PARAMETER GroupName
The name of the access group. This parameter is mandatory.

.PARAMETER GroupDescription
A description of the access group. This parameter is mandatory.

.PARAMETER OrgUnitIds
An array of organization unit IDs to be associated with the access group.

.PARAMETER UserIds
An array of user IDs to be associated with the access group.

.PARAMETER AutoIncludeNewOrgUnits
Specifies whether new organization units should be automatically included in the access group.

.EXAMPLE
PS C:\> New-NCOrgAccessGroup -OrgUnitId 123 -GroupName "Admins" -GroupDescription "Admin access group" -Verbose
Creates a new organization access group named "Admins" under the organization unit ID 123 with the description "Admin access group", with verbose output enabled.

.EXAMPLE
PS C:\> New-NCOrgAccessGroup -OrgUnitId 123 -GroupName "Admins" -GroupDescription "Admin access group" -OrgUnitIds @("OU1", "OU2") -UserIds @("User1", "User2") -AutoIncludeNewOrgUnits "true"
Creates a new organization access group named "Admins" under the organization unit ID 123 with the description "Admin access group", and associates specified organization units and users with the group, with new organization units being automatically included.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after creating the organization access group.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function New-NCOrgAccessGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$OrgUnitId,

        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [Parameter(Mandatory = $true)]
        [string]$GroupDescription,

        [string[]]$OrgUnitIds,

        [string[]]$UserIds,

        [string]$AutoIncludeNewOrgUnits
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
        
    Write-Verbose "[FUNCTION] Running New-NCOrgAccessGroup."
    $body = [ordered]@{
        groupName              = $GroupName
        groupDescription       = $GroupDescription
        orgUnitIds             = $OrgUnitIds
        userIds                = $UserIds
        autoIncludeNewOrgUnits = $AutoIncludeNewOrgUnits
    }

    $endpoint = "api/org-units/$OrgUnitId/access-groups"

    try {
        Write-Verbose "[FUNCTION] Creating new access group with endpoint: $endpoint."
        $response = $api.Post($endpoint, $Body)
        return $response
    }
    catch {
        Write-Error "Error creating new access group: $_"
    }
}