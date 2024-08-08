<#
.SYNOPSIS
Creates a new device access group in the N-central API.

.DESCRIPTION
The `New-NCDeviceAccessGroup` function creates a new device access group in the N-central API.
It requires parameters to specify the organization unit ID, group name, and group description. 
Optional parameters include arrays of device IDs and user IDs to be associated with the group.

.PARAMETER OrgUnitId
The organization unit ID under which the device access group will be created. This parameter is mandatory.

.PARAMETER GroupName
The name of the device access group. This parameter is mandatory.

.PARAMETER GroupDescription
A description of the device access group. This parameter is mandatory.

.PARAMETER DeviceIds
An array of device IDs to be associated with the device access group.

.PARAMETER UserIds
An array of user IDs to be associated with the device access group.

.EXAMPLE
PS C:\> New-NCDeviceAccessGroup -OrgUnitId 123 -GroupName "Admins" -GroupDescription "Admin devices access group" -Verbose
Creates a new device access group named "Admins" under the organization unit ID 123 with the description "Admin devices access group", with verbose output enabled.

.EXAMPLE
PS C:\> New-NCDeviceAccessGroup -OrgUnitId 123 -GroupName "Admins" -GroupDescription "Admin devices access group" -DeviceIds @("Device1", "Device2") -UserIds @("User1", "User2")
Creates a new device access group named "Admins" under the organization unit ID 123 with the description "Admin devices access group", and associates specified devices and users with the group.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after creating the device access group.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function New-NCDeviceAccessGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$OrgUnitId,

        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [Parameter(Mandatory = $true)]
        [string]$GroupDescription,
        
        [string[]]$DeviceIds,

        [string[]]$UserIds
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
        
    Write-Verbose "[FUNCTION] Running New-NCDeviceAccessGroup."
    $body = [ordered]@{
        groupName        = $GroupName
        groupDescription = $GroupDescription
        deviceIds        = $DeviceIds
        userIds          = $userIds
    }

    $endpoint = "api/org-units/$orgUnitId/device-access-groups"

    try {
        Write-Verbose "[FUNCTION] Creating new device access group with endpoint: $endpoint."
        $response = $api.Post($endpoint, $Body)
        return $response
    }
    catch {
        Write-Error "Error creating new device access group: $_"
    }
}