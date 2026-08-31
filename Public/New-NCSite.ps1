<#
.SYNOPSIS
Creates a new site for a customer in the N-central API.

.DESCRIPTION
The `New-NCSite` function creates a new site for a customer in the N-central API.
It requires several mandatory parameters to specify the customer ID, site name, and contact details.
Optional parameters include license type, external ID, phone, and address details.

.PARAMETER CustomerId
The customer ID under which the site will be created. This parameter is mandatory.

.PARAMETER SiteName
The name of the site. This parameter is mandatory.

.PARAMETER ContactFirstName
The first name of the contact person for the site. This parameter is mandatory.

.PARAMETER ContactLastName
The last name of the contact person for the site. This parameter is mandatory.

.PARAMETER LicenseType
The license type for the site.

.PARAMETER ExternalId
An external ID for the site.

.PARAMETER Phone
The phone number for the site.

.PARAMETER ContactTitle
The title of the contact person for the site.

.PARAMETER ContactEmail
The email address of the contact person for the site.

.PARAMETER ContactPhone
The phone number of the contact person for the site.

.PARAMETER ContactPhoneExt
The phone extension of the contact person for the site.

.PARAMETER ContactDepartment
The department of the contact person for the site.

.PARAMETER Street1
The primary street address of the site.

.PARAMETER Street2
The secondary street address of the site.

.PARAMETER City
The city of the site.

.PARAMETER StateProv
The state or province of the site.

.PARAMETER Country
The country of the site.

.PARAMETER PostalCode
The postal code of the site.

.EXAMPLE
PS C:\> New-NCSite -CustomerId 123 -SiteName "Main Office" -ContactFirstName "John" -ContactLastName "Doe" -Verbose
Creates a new site named "Main Office" under the customer ID 123 with contact details for John Doe, with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after creating the site.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function New-NCSite {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ContactFirstName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ContactLastName,
        [string]$LicenseType,
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

    begin { $api = Get-NCRestApiInstance }

    process {
        Write-Verbose "[FUNCTION] New-NCSite: invoked."
        $body = [ordered]@{
            siteName         = $SiteName
            contactFirstName = $ContactFirstName
            contactLastName  = $ContactLastName
        }

        if ($LicenseType) { $body.licenseType = $LicenseType }
        if ($ExternalId) { $body.externalId = $ExternalId }
        if ($Phone) { $body.phone = $Phone }
        if ($ContactTitle) { $body.contactTitle = $ContactTitle }
        if ($ContactEmail) { $body.contactEmail = $ContactEmail }
        if ($ContactPhone) { $body.contactPhone = $ContactPhone }
        if ($ContactPhoneExt) { $body.contactPhoneExt = $ContactPhoneExt }
        if ($ContactDepartment) { $body.contactDepartment = $ContactDepartment }
        if ($Street1) { $body.street1 = $Street1 }
        if ($Street2) { $body.street2 = $Street2 }
        if ($City) { $body.city = $City }
        if ($StateProv) { $body.stateProv = $StateProv }
        if ($Country) { $body.country = $Country }
        if ($PostalCode) { $body.postalCode = $PostalCode }

        if (-not $PSCmdlet.ShouldProcess($SiteName, 'Create site')) { return }
        $api.Post("api/customers/$CustomerId/sites", $body)
    }
}