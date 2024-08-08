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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [int]$itemId,

        [Parameter(Mandatory = $true)]
        [ValidateSet("AutomationPolicy", "Script", "MacScript")]
        [string]$taskType,

        [Parameter(Mandatory = $true)]
        [int]$customerId,

        [Parameter(Mandatory = $true)]
        [int]$deviceId,

        [Parameter(Mandatory = $true)]
        [ValidateSet("LocalSystem", "DeviceCredentials", "CustomCredentials")]
        [string]$credentialType,

        [string]$username,

        [string]$password
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance
    
    Write-Verbose "[FUNCTION] Running New-NCScheduledTask."
    $credential = @{
        type = $credentialType
    }

    if ($credentialType -eq "CustomCredentials") {
        if (-not $username -or -not $password) {
            throw "Username and password are required for CustomCredentials."
        }
        $credential.username = $username
        $credential.password = $password
    }

    $body = @{
        name       = $name
        itemId     = $itemId
        taskType   = $taskType
        customerId = $customerId
        deviceId   = $deviceId
        credential = $credential
        parameters = $parameters
    }

    $endpoint = "api/scheduled-tasks/direct"

    try {
        Write-Verbose "[FUNCTION] Creating scheduled task for endpoint: $endpoint."
        $response = $api.Post($endpoint, $body)
        return $response
    }
    catch {
        Write-Error "Error creating scheduled task: $_"
    }
}