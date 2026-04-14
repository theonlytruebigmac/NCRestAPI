<#
.SYNOPSIS
Creates a new site for a customer in the N-central API.

.DESCRIPTION
The `New-NCSite` function creates a new site for a customer in the N-central API.
It requires several mandatory parameters to specify the customer ID, site name, and contact details.
Optional parameters include license type, external ID, phone, and address details.

.PARAMETER customerId
The customer ID under which the site will be created. This parameter is mandatory.

.PARAMETER siteName
The name of the site. This parameter is mandatory.

.PARAMETER contactFirstName
The first name of the contact person for the site. This parameter is mandatory.

.PARAMETER contactLastName
The last name of the contact person for the site. This parameter is mandatory.

.PARAMETER licenseType
The license type for the site.

.PARAMETER externalId
An external ID for the site.

.PARAMETER phone
The phone number for the site.

.PARAMETER contactTitle
The title of the contact person for the site.

.PARAMETER contactEmail
The email address of the contact person for the site.

.PARAMETER contactPhone
The phone number of the contact person for the site.

.PARAMETER contactPhoneExt
The phone extension of the contact person for the site.

.PARAMETER contactDepartment
The department of the contact person for the site.

.PARAMETER street1
The primary street address of the site.

.PARAMETER street2
The secondary street address of the site.

.PARAMETER city
The city of the site.

.PARAMETER stateProv
The state or province of the site.

.PARAMETER country
The country of the site.

.PARAMETER postalCode
The postal code of the site.

.EXAMPLE
PS C:\> New-NCSite -customerId 123 -siteName "Main Office" -contactFirstName "John" -contactLastName "Doe" -Verbose
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

    $api = Get-NCRestApiInstance

    Write-Verbose "[FUNCTION] New-NCSite: invoked."
    $body = [ordered]@{
        siteName         = $siteName
        contactFirstName = $contactFirstName
        contactLastName  = $contactLastName
    }

    if ($licenseType) { $body["licenseType"] = $licenseType }
    if ($externalId) { $body["externalId"] = $externalId }
    if ($phone) { $body["phone"] = $phone }
    if ($contactTitle) { $body["contactTitle"] = $contactTitle }
    if ($contactEmail) { $body["contactEmail"] = $contactEmail }
    if ($contactPhone) { $body["contactPhone"] = $contactPhone }
    if ($contactPhoneExt) { $body["contactPhoneExt"] = $contactPhoneExt }
    if ($contactDepartment) { $body["contactDepartment"] = $contactDepartment }
    if ($street1) { $body["street1"] = $street1 }
    if ($street2) { $body["street2"] = $street2 }
    if ($city) { $body["city"] = $city }
    if ($stateProv) { $body["stateProv"] = $stateProv }
    if ($country) { $body["country"] = $country }
    if ($postalCode) { $body["postalCode"] = $postalCode }

    $endpoint = "api/customers/$customerId/sites"

        Write-Verbose "[FUNCTION] Creating new site with endpoint: $endpoint."
        if (-not $PSCmdlet.ShouldProcess($siteName, 'Create site')) { return }

        $response = $api.Post($endpoint, $body)
        return $response
}