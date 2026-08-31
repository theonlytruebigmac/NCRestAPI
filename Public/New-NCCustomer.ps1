<#
.SYNOPSIS
Creates a new customer in the N-central API.

.DESCRIPTION
The `New-NCCustomer` function creates a new customer in the N-central API.
It requires several mandatory parameters to specify the service organization ID, customer name, and contact details. 
Optional parameters include license type, external ID, phone, and address details.

.PARAMETER SoId
The service organization ID under which the customer will be created. This parameter is mandatory.

.PARAMETER CustomerName
The name of the customer. This parameter is mandatory.

.PARAMETER ContactFirstName
The first name of the contact person for the customer. This parameter is mandatory.

.PARAMETER ContactLastName
The last name of the contact person for the customer. This parameter is mandatory.

.PARAMETER LicenseType
The license type for the customer.

.PARAMETER ExternalId
An external ID for the customer.

.PARAMETER Phone
The phone number for the customer.

.PARAMETER ContactTitle
The title of the contact person for the customer.

.PARAMETER ContactEmail
The email address of the contact person for the customer.

.PARAMETER ContactPhone
The phone number of the contact person for the customer.

.PARAMETER ContactPhoneExt
The phone extension of the contact person for the customer.

.PARAMETER ContactDepartment
The department of the contact person for the customer.

.PARAMETER Street1
The primary street address of the customer.

.PARAMETER Street2
The secondary street address of the customer.

.PARAMETER City
The city of the customer.

.PARAMETER StateProv
The state or province of the customer.

.PARAMETER Country
The country of the customer.

.PARAMETER PostalCode
The postal code of the customer.

.EXAMPLE
PS C:\> New-NCCustomer -SoId 123 -CustomerName "Acme Corp" -ContactFirstName "John" -ContactLastName "Doe" -Verbose
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
            customerName     = $CustomerName
            contactFirstName = $ContactFirstName
            contactLastName  = $ContactLastName
        }

        if ($LicenseType)       { $body.licenseType       = $LicenseType }
        if ($ExternalId)        { $body.externalId        = $ExternalId }
        if ($Phone)             { $body.phone             = $Phone }
        if ($ContactTitle)      { $body.contactTitle      = $ContactTitle }
        if ($ContactEmail)      { $body.contactEmail      = $ContactEmail }
        if ($ContactPhone)      { $body.contactPhone      = $ContactPhone }
        if ($ContactPhoneExt)   { $body.contactPhoneExt   = $ContactPhoneExt }
        if ($ContactDepartment) { $body.contactDepartment = $ContactDepartment }
        if ($Street1)           { $body.street1           = $Street1 }
        if ($Street2)           { $body.street2           = $Street2 }
        if ($City)              { $body.city              = $City }
        if ($StateProv)         { $body.stateProv         = $StateProv }
        if ($Country)           { $body.country           = $Country }
        if ($PostalCode)        { $body.postalCode        = $PostalCode }

        if (-not $PSCmdlet.ShouldProcess($CustomerName, 'Create customer')) { return }
        $api.Post("api/service-orgs/$SoId/customers", $body)
    }
}