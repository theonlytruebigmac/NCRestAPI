<#
.SYNOPSIS
Creates a new customer in the N-central API.

.DESCRIPTION
The `New-NCCustomer` function creates a new customer in the N-central API.
It requires several mandatory parameters to specify the service organization ID, customer name, and contact details. 
Optional parameters include license type, external ID, phone, and address details.

.PARAMETER soId
The service organization ID under which the customer will be created. This parameter is mandatory.

.PARAMETER customerName
The name of the customer. This parameter is mandatory.

.PARAMETER contactFirstName
The first name of the contact person for the customer. This parameter is mandatory.

.PARAMETER contactLastName
The last name of the contact person for the customer. This parameter is mandatory.

.PARAMETER licenseType
The license type for the customer.

.PARAMETER externalId
An external ID for the customer.

.PARAMETER phone
The phone number for the customer.

.PARAMETER contactTitle
The title of the contact person for the customer.

.PARAMETER contactEmail
The email address of the contact person for the customer.

.PARAMETER contactPhone
The phone number of the contact person for the customer.

.PARAMETER contactPhoneExt
The phone extension of the contact person for the customer.

.PARAMETER contactDepartment
The department of the contact person for the customer.

.PARAMETER street1
The primary street address of the customer.

.PARAMETER street2
The secondary street address of the customer.

.PARAMETER city
The city of the customer.

.PARAMETER stateProv
The state or province of the customer.

.PARAMETER country
The country of the customer.

.PARAMETER postalCode
The postal code of the customer.

.EXAMPLE
PS C:\> New-NCCustomer -soId 123 -customerName "Acme Corp" -contactFirstName "John" -contactLastName "Doe" -Verbose
Creates a new customer named "Acme Corp" under the service organization ID 123 with contact details for John Doe, with verbose output enabled.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the response from the N-central API after creating the customer.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function New-NCCustomer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$SoId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CustomerName,
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

        Write-Verbose "[FUNCTION] New-NCCustomer: invoked."
        $body = [ordered]@{
            customerName     = $customerName
            contactFirstName = $contactFirstName
            contactLastName  = $contactLastName
        }

        if ($licenseType)       { $body.licenseType       = $licenseType }
        if ($externalId)        { $body.externalId        = $externalId }
        if ($phone)             { $body.phone             = $phone }
        if ($contactTitle)      { $body.contactTitle      = $contactTitle }
        if ($contactEmail)      { $body.contactEmail      = $contactEmail }
        if ($contactPhone)      { $body.contactPhone      = $contactPhone }
        if ($contactPhoneExt)   { $body.contactPhoneExt   = $contactPhoneExt }
        if ($contactDepartment) { $body.contactDepartment = $contactDepartment }
        if ($street1)           { $body.street1           = $street1 }
        if ($street2)           { $body.street2           = $street2 }
        if ($city)              { $body.city              = $city }
        if ($stateProv)         { $body.stateProv         = $stateProv }
        if ($country)           { $body.country           = $country }
        if ($postalCode)        { $body.postalCode        = $postalCode }

        if (-not $PSCmdlet.ShouldProcess($customerName, 'Create customer')) { return }
        $api.Post("api/service-orgs/$soId/customers", $body)
    }
}