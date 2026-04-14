# NCRestAPI

PowerShell module for the [N-able N-central](https://www.n-able.com/) public REST API.
Handles authentication, token refresh, pagination, and retries so you can focus on automation.

## Features

- Token-based authentication with automatic refresh (`/api/auth/authenticate`, `/api/auth/refresh`)
- Tokens held in memory as `SecureString` — never written to disk or environment
- Unified request path with automatic retry on 429 / 5xx, 60 s timeout, and URL-encoded query strings
- Verbose logging scrubs JWTs from output
- `-All` auto-pagination on large list endpoints

## Installation

```powershell
Install-Module -Name NCRestAPI
```

Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7).

## Quick start

```powershell
Import-Module NCRestAPI

# Connect
Connect-NCentral -BaseUrl 'n-central.example.com' -ApiToken $env:NC_API_TOKEN

# Or Set-NCRestConfig (same thing, older name)
Set-NCRestConfig -BaseUrl 'n-central.example.com' -ApiToken $env:NC_API_TOKEN

# Use
Get-NCDevices -OrgUnitId 42 -All            # auto-paginates
Get-NCDevices -DeviceId 987654321           # single device
Get-NCCustomers -PageSize 100

# Pipelines (Customer -> sites -> devices, etc.)
Get-NCServiceOrgs | Get-NCCustomers
Get-NCCustomers -All | Get-NCSites
Get-NCDevices -All | Where-Object status -eq 'Decommissioned' | Remove-NCDevice -Force

# Tear down
Disconnect-NCentral
```

Token expirations can be overridden (e.g. short-lived tokens in CI):

```powershell
Connect-NCentral -BaseUrl ... -ApiToken ... -AccessTokenExpiration '15m' -RefreshTokenExpiration '1h'
```

## Common cmdlets

| Command | Endpoint(s) |
| --- | --- |
| `Connect-NCentral` / `Set-NCRestConfig` | `/api/auth/authenticate` |
| `Disconnect-NCentral` / `Get-NCRestApiInfo -Kill` | — |
| `Get-NCDevices` | `/api/devices`, `/api/devices/{id}`, `/api/org-units/{id}/devices` |
| `Get-NCCustomers` | `/api/customers`, `/api/customers/{id}`, `/api/service-orgs/{id}/customers` |
| `Get-NCSites` | `/api/sites`, `/api/sites/{id}`, `/api/customers/{id}/sites` |
| `Get-NCOrgUnits` | `/api/org-units`, `/api/org-units/{id}`, `/api/org-units/{id}/children` |
| `Get-NCServiceOrgs` | `/api/service-orgs`, `/api/service-orgs/{id}/customers` |
| `Get-NCAccessGroups` | `/api/access-groups`, `/api/org-units/{id}/access-groups` |
| `Get-NCActiveIssues` | `/api/org-units/{id}/active-issues` |
| `Get-NCDeviceAssets` | `/api/devices/{id}/assets` |
| `Get-NCDeviceServices` | `/api/devices/{id}/service-monitor-status` |
| `Get-NCDeviceScheduledTasks` | `/api/devices/{id}/scheduled-tasks` |
| `Get-NCDeviceActivationKey` | `/api/devices/{id}/activation-key` |
| `Get-NCDeviceMaintenanceWindows` | `GET /api/devices/{id}/maintenance-windows` |
| `New-NCMaintenanceWindows` / `Set-NCMaintenanceWindows` / `Remove-NCMaintenanceWindows` | Maintenance-window CRUD at `/api/devices/maintenance-windows` |
| `Get-NCAssetLifecycle` / `Set-NCAssetLifecycle` / `Update-NCAssetLifecycle` | `/api/devices/{id}/assets/lifecycle-info` (GET / PUT / PATCH) |
| `New-NCDevice` | `POST /api/device` (device enrollment) |
| `Remove-NCDevice` | `DELETE /api/devices/{id}` (supports `-WhatIf`/`-Confirm`) |
| `Get-NCSoftwareInstallers` / `New-NCSoftwareDownloadLink` | `/api/customers/{id}/software/installers` |
| `Get-NCReport` / `New-NCPatchComparisonReport` | `/api/report/...` |
| `Get-NCStandardPsaCustomerMapping` / `Test-NCStandardPsaCredential` / `Get-NCCustomPsaTicket` | PSA integrations (`/api/standard-psa`, `/api/custom-psa`) |
| `Get-NCDeviceProperty` / `Set-NCDeviceProperty` | `/api/devices/{id}/custom-properties[/{propId}]` |
| `Get-NCOrgProperty` / `Set-NCOrgProperty` | `/api/org-units/{id}/custom-properties[/{propId}]` |
| `Get-NCDefaultOrgProperty` / `Set-NCDefaultOrgProperty` | `/api/org-units/{id}/org-custom-property-defaults[/{propId}]` |
| `Get-NCDefaultDeviceProperty` | `/api/org-units/{id}/custom-properties/device-custom-property-defaults/{propId}` |
| `Get-NCFilters` | `/api/device-filters` |
| `Get-NCJobStatus` | `/api/org-units/{id}/job-statuses` |
| `Get-NCApplianceTask` | `/api/appliance-tasks/{id}` |
| `Get-NCScheduledTasks` / `Get-NCScheduledTaskStatus` | `/api/scheduled-tasks/...` |
| `New-NCScheduledTask` | `POST /api/scheduled-tasks/direct` |
| `Get-NCRegTokens` | `/api/{customers,sites,org-units}/{id}/registration-token` |
| `Get-NCServerInfo` | `/api`, `/api/server-info`, `/api/server-info/extra`, `/api/health` |
| `Get-NCUsers` / `Get-NCUserRoles` / `New-NCUserRole` | `/api/users`, `/api/org-units/{id}/users`, `.../user-roles` |
| `New-NCCustomer` / `New-NCServiceOrg` / `New-NCSite` | Customer / SO / site creation |
| `New-NCDeviceAccessGroup` / `New-NCOrgAccessGroup` | Access-group creation |
| `Get-NCRestData` | Escape hatch for any endpoint not yet wrapped (`-Method Get/Post/Put/Patch/Delete`, `-Body`) |
| `Get-NCApiLinks` | Hypermedia `_links` at `/api`, `/api/custom-psa*`, `/api/standard-psa` |

Run `Get-Help <cmdlet> -Examples` for usage on any command.

## Escape hatch

Need to call an endpoint the module doesn't wrap yet? Use `Get-NCRestData`:

```powershell
Get-NCRestData -Endpoint 'api/device-filters'
```

Or reach for the underlying instance directly:

```powershell
$api = Get-NCRestApiInstance
$api.Get('api/some/new/endpoint')
$api.Post('api/some/endpoint', @{ key = 'value' })
```

## Debugging

Every cmdlet honors `-Verbose`:

```powershell
Get-NCDevices -DeviceId 123 -Verbose
```

Tokens are masked in verbose output.

## Security notes

- Tokens live in memory as `SecureString` for the lifetime of the PowerShell process
- `Disconnect-NCentral` disposes the instance and zeroes cached references
- The module does not persist tokens to disk or to user-scoped environment variables

## Development

```powershell
# Static analysis
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1

# Tests
Invoke-Pester ./Tests
```

CI runs on Ubuntu, Windows, and macOS under `.github/workflows/ci.yml`.

## Contributing

Issues and PRs welcome at [github.com/theonlytruebigmac/NCRestAPI](https://github.com/theonlytruebigmac/NCRestAPI).

## License

Apache 2.0 - see [LICENSE](LICENSE).
