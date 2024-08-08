<#
.SYNOPSIS
Creates a new service organization in the N-central API.

.DESCRIPTION
The `New-NCServiceOrg` function creates a new service organization in the N-central API.
It requires several mandatory parameters to specify the service organization name and contact details.
Optional parameters include external ID, phone, and address details.

.PARAMETER SoName
The name of the service organization. This parameter is mandatory.

.PARAMETER ContactFirstName
The first name of the contact person for the service organization. This parameter is mandatory.

.PARAMETER ContactLastName
The last name of the contact person for the service organization. This parameter is mandatory.

.PARAMETER ExternalId
An external ID for the service organization.

.PARAMETER Phone
The phone number for the service organization.

.PARAMETER ContactTitle
The title of the contact person for the service organization.

.PARAMETER ContactEmail
The email address of the contact person for the service organization.

.PARAMETER ContactPhone
The phone number of the contact person for the service organization.

.PARAMETER ContactPhoneExt
The phone extension of the contact person for the service organization.

.PARAMETER ContactDepartment
The department of the contact person for the service organization.

.PARAMETER Street1
The primary street address of the service organization.

.PARAMETER Street2
The secondary street address of the service organization.

.PARAMETER City
The city of the service organization.

.PARAMETER StateProv
The state or province of the service organization.

.PARAMETER Country
The country of the service organization.

.PARAMETER PostalCode
The postal code of the service organization.

.EXAMPLE
PS C:\> New-NCServiceOrg -SoName "Tech Corp" -ContactFirstName "Jane" -ContactLastName "Doe" -Verbose
Creates a new service organization named "Tech Corp" with contact details for Jane Doe, with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after creating the service organization.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function New-NCServiceOrg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SoName,

        [Parameter(Mandatory = $true)]
        [string]$ContactFirstName,

        [Parameter(Mandatory = $true)]
        [string]$ContactLastName,

        [string]$ExternalId,

        [string]$Phone,

        [string]$ContactTitle,

        [string]$ContactEmail,

        [string]$ContactPhone,

        [string]$ContactPhoneExt,

        [string]$ContactDepartment,

        [string]$Street1,

        [string]$Street2,

        [string]$City,

        [string]$StateProv,

        [string]$Country,

        [string]$PostalCode
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance

    Write-Verbose "[FUNCTION] Running New-NCServiceOrg."
    $body = [ordered]@{
        soName           = $SoName
        contactFirstName = $ContactFirstName
        contactLastName  = $ContactLastName
    }

    if ($ExternalId) { $body["externalId"] = $ExternalId }
    if ($Phone) { $body["phone"] = $Phone }
    if ($ContactTitle) { $body["contactTitle"] = $ContactTitle }
    if ($ContactEmail) { $body["contactEmail"] = $ContactEmail }
    if ($ContactPhone) { $body["contactPhone"] = $ContactPhone }
    if ($ContactPhoneExt) { $body["contactPhoneExt"] = $ContactPhoneExt }
    if ($ContactDepartment) { $body["contactDepartment"] = $ContactDepartment }
    if ($Street1) { $body["street1"] = $Street1 }
    if ($Street2) { $body["street2"] = $Street2 }
    if ($City) { $body["city"] = $City }
    if ($StateProv) { $body["stateProv"] = $StateProv }
    if ($Country) { $body["country"] = $Country }
    if ($PostalCode) { $body["postalCode"] = $PostalCode }

    $endpoint = "api/service-orgs"

    try {
        Write-Verbose "[FUNCTION] Creating new service organization with endpoint: $endpoint."
        $response = $api.Post($endpoint, $body)
        return $response
    }
    catch {
        Write-Error "Error creating new service organization: $_"
    }
}