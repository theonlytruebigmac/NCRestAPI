<#
.SYNOPSIS
Creates a direct-support scheduled task against a specific device in the N-central API.

.DESCRIPTION
The `New-NCScheduledTask` function creates a direct-support scheduled task against a specific device. The task will be executed immediately against the device specified in the request payload.

.PARAMETER name
Specifies the name of the task. This value must be unique.

.PARAMETER itemId
Specifies the ID of the remote execution item.

.PARAMETER taskType
Specifies the type of the task. Supported values are: AutomationPolicy, Script, or MacScript.

.PARAMETER customerId
Specifies the ID of the customer.

.PARAMETER deviceId
Specifies the ID of the device.

.PARAMETER credentialType
Specifies the type of credential for the task. Supported values are: LocalSystem, DeviceCredentials, CustomCredentials.

.PARAMETER username
Specifies the username for the credential (required for CustomCredentials).

.PARAMETER password
Specifies the password for the credential (required for CustomCredentials).

.PARAMETER parameters
Specifies the parameters for the task.

.EXAMPLE
PS C:\> New-NCScheduledTask -name "Test Task" -itemId 1 -taskType "Script" -customerId 100 -deviceId 987654321 -credentialType "LocalSystem" -parameters @(@{name="CommandLine"; value="killprocess.vbs /process:33022"}) -Verbose
Creates a direct-support scheduled task with the specified parameters and enables verbose output.

.EXAMPLE
PS C:\> New-NCScheduledTask -name "Test Task" -itemId 1 -taskType "Script" -customerId 100 -deviceId 987654321 -credentialType "CustomCredentials" -username "admin" -password "password" -parameters @(@{name="CommandLine"; value="killprocess.vbs /process:33022"}) -Verbose
Creates a direct-support scheduled task with custom credentials and specified parameters and enables verbose output.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns the created scheduled task information from the specified N-central API endpoint.

.NOTES
Author: Zach Frazier
Website: https://github.com/soybigmac/NCRestAPI
#>

function New-NCScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'credentialType', Justification = 'Enum-like discriminator, not a password.')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [int]$itemId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("AutomationPolicy", "Script", "MacScript")]
        [string]$taskType,

        [Parameter(Mandatory = $true)]
        [int]$customerId,

        [Parameter(Mandatory = $true)]
        [int]$deviceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("LocalSystem", "DeviceCredentials", "CustomCredentials")]
        [string]$credentialType,

        [pscredential]$Credential,

        [array]$parameters = @()
    )

    $api = Get-NCRestApiInstance

    Write-Verbose "[FUNCTION] Running New-NCScheduledTask."
    # NOTE: local var named anything other than $Credential to avoid collision with
    # the [pscredential]$Credential parameter (PowerShell var names are case-insensitive).
    $credBody = @{ type = $credentialType }

    if ($credentialType -eq 'CustomCredentials') {
        if (-not $Credential) {
            throw "A -Credential (PSCredential) is required for CustomCredentials."
        }
        $credBody.username = $Credential.UserName
        $credBody.password = $Credential.GetNetworkCredential().Password
    }

    $body = @{
        name       = $name
        itemId     = $itemId
        taskType   = $taskType
        customerId = $customerId
        deviceId   = $deviceId
        credential = $credBody
        parameters = $parameters
    }

    if (-not $PSCmdlet.ShouldProcess($name, 'Create scheduled task')) { return }
    $api.Post('api/scheduled-tasks/direct', $body)
}