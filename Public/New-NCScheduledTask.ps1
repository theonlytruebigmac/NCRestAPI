<#
.SYNOPSIS
Creates a direct-support scheduled task against a specific device in the N-central API.

.DESCRIPTION
The `New-NCScheduledTask` function creates a direct-support scheduled task against a specific device. The task will be executed immediately against the device specified in the request payload.

.PARAMETER Name
Specifies the name of the task. This value must be unique.

.PARAMETER ItemId
Specifies the ID of the remote execution item.

.PARAMETER TaskType
Specifies the type of the task. Supported values are: AutomationPolicy, Script, or MacScript.

.PARAMETER CustomerId
Specifies the ID of the customer.

.PARAMETER DeviceId
Specifies the ID of the device.

.PARAMETER CredentialType
Specifies the type of credential for the task. Supported values are: LocalSystem, DeviceCredentials, CustomCredentials.

.PARAMETER Credential
A [pscredential] supplying the username/password. Required when -CredentialType is CustomCredentials.

.PARAMETER Parameters
Specifies the parameters for the task.

.EXAMPLE
PS C:\> New-NCScheduledTask -Name "Test Task" -ItemId 1 -TaskType "Script" -CustomerId 100 -DeviceId 987654321 -CredentialType "LocalSystem" -Parameters @(@{name="CommandLine"; value="killprocess.vbs /process:33022"}) -Verbose
Creates a direct-support scheduled task with the specified parameters and enables verbose output.

.EXAMPLE
PS C:\> New-NCScheduledTask -Name "Test Task" -ItemId 1 -TaskType "Script" -CustomerId 100 -DeviceId 987654321 -CredentialType "CustomCredentials" -Credential (Get-Credential) -Parameters @(@{name="CommandLine"; value="killprocess.vbs /process:33022"}) -Verbose
Creates a direct-support scheduled task with custom credentials (prompted via Get-Credential).

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the created scheduled task information from the specified N-central API endpoint.

.NOTES
Author: Zach Frazier
Website: https://github.com/theonlytruebigmac/NCRestAPI
#>

function New-NCScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'credentialType', Justification = 'Enum-like discriminator, not a password.')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [int]$ItemId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("AutomationPolicy", "Script", "MacScript")]
        [string]$TaskType,
        [Parameter(Mandatory = $true)]
        [int]$CustomerId,

        [Parameter(Mandatory = $true)]
        [int]$DeviceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("LocalSystem", "DeviceCredentials", "CustomCredentials")]
        [string]$CredentialType,
        [pscredential]$Credential,

        [array]$Parameters = @()
    )

    $api = Get-NCRestApiInstance

    Write-Verbose "[FUNCTION] New-NCScheduledTask: invoked."
    $credBody = @{ type = $CredentialType }

    if ($CredentialType -eq 'CustomCredentials') {
        if (-not $Credential) {
            throw "A -Credential (PSCredential) is required for CustomCredentials."
        }
        $credBody.username = $Credential.UserName
        $credBody.password = $Credential.GetNetworkCredential().Password
    }

    $body = @{
        name       = $Name
        itemId     = $ItemId
        taskType   = $TaskType
        customerId = $CustomerId
        deviceId   = $DeviceId
        credential = $credBody
        parameters = $Parameters
    }

    if (-not $PSCmdlet.ShouldProcess($Name, 'Create scheduled task')) { return }
    $api.Post('api/scheduled-tasks/direct', $body)
}