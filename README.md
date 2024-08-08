# NCRestAPI

## Description

This PowerShell module is designed to interact with the Public REST API for N-central (c) RMM by N-able (R). It provides a convenient way to automate tasks and retrieve information from the N-central platform.

## Features

- Authenticate with the N-central REST API
- Retrieve device information
- Manage alerts and notifications
- Create and manage tickets
- Execute scripts on devices

## Installation

To install the module, run the following command:

```powershell
Install-Module -Name NCRestAPI
```

## Usage

1. Import the module:

```powershell
Import-Module -Name NCRestAPI
```

2. Load N-central URL, Json Web Token (JWT), Optional: Access Token Expiry, and Refresh Token Expiry for module use:

```powershell
Set-NCRestConfig -BaseURL "https://URL" -APIToken "JWT" -AccessTokenExpiration "120s" -RefreshTokenExpiration "120s"
```

3. Retrieve device information:

```powershell
Get-NCDevices -DeviceId "device_id"
```

## Additional Usage

I've added a command Get-NCRestData that allows you to pass any -Endpoint from the N-central REST API. As new endpoints come out, you can use this as a workaround until the module gets updated. Right now I only plan to use the GET methods.

```powershell
Get-NCRestData -Endpoint "api/device-filters"
```

## Additional Debugging

1. The Verbose parameter can be used on each command to see additional information from the NCRestAPI call.

```powershell
Get-NCDevices -Verbose
```

2. Help is avaliable with examples

```powershell
Get-Help Get-NCCustomers -examples
```

## N-Central Rest API Endpoints

| N-central Operations | Method | Endpoint                                                                                  | Command                     | Created                                               |
| -------------------- | ------ | ----------------------------------------------------------------------------------------- | --------------------------- | ----------------------------------------------------- |
| Access Groups        | POST   | /api/org-units/{orgUnitId}/device-access-groups                                           | New-NCDeviceAccessGroup     | ✅                                                    |
| Access Groups        | GET    | /api/org-units/{orgUnitId}/access-groups                                                  | Get-NCAccessGroups          | ✅                                                    |
| Access Groups        | POST   | /api/org-units/{orgUnitId}/access-groups                                                  | New-NCOrgAccessGroup        | ✅                                                    |
| Access Groups        | GET    | /api/access-groups                                                                        | Get-NCAccessGroups          | ✅                                                    |
| Access Groups        | GET    | /api/access-groups/{accessGroupId}                                                        | Get-NCAccessGroups          | ✅                                                    |
| Active Issues        | GET    | /api/org-nits/{orgUnitId}/active-issues                                                   | Get-NCActiveIssues          | ✅                                                    |
| API-Service          | POST   | /api/server-info/exra/authenticated                                                       | Get-NCRestInfo              | ❌                                                    |
| API-Service          | GET    | /api                                                                                      | Get-NCRestInfo              | ✅                                                    |
| API-Service          | GET    | /api/server-info                                                                          | Get-NCRestInfo              | ✅                                                    |
| API-Service          | GET    | /api/server-info/extra                                                                    | Get-NCRestInfo              | ✅                                                    |
| API-Service          | GET    | /api/health                                                                               | Get-NCRestInfo              | ✅                                                    |
| Custom Properties    | PUT    | /api/org-units/{orgUnitId}/org-custom-property-defaults                                   | Set-NCDefaultOrgProperty    | ✅ |
| Custom Properties    | GET    | /api/org-units/{orgUnitId}/custom-properties/{propertyId}                                 | Get-NCOrgProperty           | ✅                                                    |
| Custom Properties    | PUT    | /api/org-units/{orgUnitId}/custom-properties/{propertyId}                                 | Set-NCOrgProperty           | ✅ |
| Custom Properties    | GET    | /api/devices/{deviceId}/custom-properties/{propertyId}                                    | Get-NCDeviceProperty        | ✅                                                    |
| Custom Properties    | PUT    | /api/devices/{deviceId}/custom-properties/{propertyId}                                    | Set-NCDeviceProperty        | ✅                                                    |
| Custom Properties    | GET    | /api/org-units/{orgUnitId}/org-custom-property-defaults/{propertyId}                      | Get-NCDefaultOrgProperty    | ✅                                                    |
| Custom Properties    | GET    | /api/org-units/{orgUnitID}/custom-properties                                              | Get-NCOrgProperty           | ✅                                                    |
| Custom Properties    | GET    | /api/org-units/{orgUnitId}/custom-properties/device-custom-property-defaults/{propertyId} | Get-NCDefaultDeviceProperty | ✅                                                    |
| Custom Properties    | GET    | /api/devices/{deviceId}/custom-properties                                                 | Get-NCDeviceProperty        | ✅                                                    |
| Device Filters       | GET    | /api/filters                                                                              | Get-NCFilters               | ✅                                                    |
| Device Tasks         | GET    | /api/devices/{deviceId}/scheduled-tasks                                                   | Get-NCDeviceTasks           | ✅                                                    |
| Devices              | GET    | /api/org-units/{orgUnitId}/devices                                                        | Get-NCDevices               | ✅                                                    |
| Devices              | GET    | /api/devices                                                                              | Get-NCDevices               | ✅                                                    |
| Devices              | GET    | /api/devices/{deviceId}                                                                   | Get-NCDevices               | ✅                                                    |
| Devices              | GET    | /api/devices/{deviceId}/service-monitor-status                                            | Get-DeviceServices          | ✅                                                    |
| Devices              | GET    | /api/devices/{deviceId}/assets                                                            | Get-NCDeviceAssets          | ✅                                                    |
| Devices              | GET    | /api/appliance-tasks/{taskId}                                                             | Get-NCApplianceTask         | ✅                                                    |
| Job Statuses         | GET    | /api/org-units/{orgUnitId}/job-statuses                                                   | Get-NCJobStatus             | ✅                                                    |
| Organizational Units | GET    | /api/service-orgs                                                                         | Get-NCServiceOrgs           | ✅                                                    |
| Organizational Units | POST   | /api/service-orgs                                                                         | New-NCServiceOrg            | ✅                                                    |
| Organizational Units | GET    | /api/service-orgs/{soId}/customers                                                        | Get-NCCustomers             | ✅                                                    |
| Organizational Units | POST   | /api/service-orgs/{soId}/customers                                                        | New-NCCustomer              | ✅                                                    |
| Organizational Units | GET    | /api/customers/{customerId}/sites                                                         | Get-NCSites                 | ✅                                                    |
| Organizational Units | POST   | /api/customers/{customerId}/sites                                                         | New-NCSite                  | ✅                                                    |
| Organizational Units | GET    | /api/sites                                                                                | Get-NCSites                 | ✅                                                    |
| Organizational Units | GET    | /api/sites/{siteId}                                                                       | Get-NCSites                 | ✅                                                    |
| Organizational Units | GET    | /api/service-orgs/{soId}                                                                  | Get-NCCustomers             | ✅                                                    |
| Organizational Units | GET    | /api/org-units                                                                            | Get-NCOrgUnits              | ✅                                                    |
| Organizational Units | GET    | /api/org-units/{orgUnitId}                                                                | Get-NCOrgUnits              | ✅                                                    |
| Organizational Units | GET    | /api/org-units/{orgUnitId}/children                                                       | Get-NCOrgUnits              | ✅                                                    |
| Organizational Units | GET    | /api/customers                                                                            | Get-NCCustomers             | ✅                                                    |
| Organizational Units | GET    | /api/customers/{customerId}                                                               | Get-NCCustomers             | ✅                                                    |
| PSA                  | POST   | /api/standard-psa/{psatype}/credential                                                    | Test-PSACredentials         | ❌                                                    |
| PSA                  | POST   | /api/custom-psa/tickets/{customPsaTicketId}                                               | Get-NCCustomPSATicket       | ❌                                                    |
| PSA                  | GET    | /api/standard-psa                                                                         | TBD                         | ❌                                                    |
| PSA                  | GET    | /api/custom-psa                                                                           | TBD                         | ❌                                                    |
| PSA                  | GET    | /api/custom-psa/tickets                                                                   | TBD                         | ❌                                                    |
| Registration Tokens  | GET    | /api/sites/{siteId}/registration-token                                                    | Get-NCRegTokens             | ✅                                                    |
| Registration Tokens  | GET    | /api/org-units/{orgUnitId}/registration-token                                             | Get-NCRegTokens             | ✅                                                    |
| Registration Tokens  | GET    | /api/customers/{customerId}/registration-token                                            | Get-NCRegTokens             | ✅                                                    |
| Scheduled Tasks      | POST   | /api/scheduled-tasks/direct                                                               | Create-NCScheduledTask      | ✅                                                    |
| Scheduled Tasks      | GET    | /api/scheduled-tasks                                                                      | Get-NCScheduledTasks        | ⚠️                                                    |
| Scheduled Tasks      | GET    | /api/scheduled-tasks/{taskId}                                                             | Get-NCScheduledTasks        | ✅                                                    |
| Scheduled Tasks      | GET    | /api/scheduled-tasks/{taskId}/status                                                      | Get-NCScheduledTasksStatus  | ✅                                                    |
| Scheduled Tasks      | GET    | /api/scheduled-tasks/{taskId}/status/details                                              | Get-NCScheduledTasksStatus  | ✅                                                    |
| User Roles           | GET    | /api/org-units/{orgUnitId}/user-roles                                                     | Get-NCUserRoles             | ✅                                                    |
| User Roles           | POST   | /api/org-units/{orgUnitId}/user-roles                                                     | Get-NCUserRoles             | ✅                                                    |
| User Roles           | GET    | /api/org-units/{orgUnitId/user-roles/{userRoleId}}                                        | Get-NCUserRoles             | ✅                                                    |
| User                 | GET    | /api/users                                                                                | Get-NCUsers                 | ✅                                                    |
| User                 | GET    | /api/org-units/{orgUnitId}/user                                                           | Get-NCUsers                 | ✅                                                    |

### Legend

| ✅ = Functioning | ⚠️ = In Process | ❌ = Pending |
| ---------------- | --------------- | ------------ |

## Contributing

Contributions are welcome! If you have any suggestions or find any issues, please open an issue or submit a pull request on the [GitHub repository](https://github.com/soybigmac/NCRest).

## License

This project is licensed under the Apache License. See the [LICENSE](LICENSE) file for more information.

## Contact

For any questions or inquiries, please contact us at [@soybigmac](https://github.com/soybigmac).
