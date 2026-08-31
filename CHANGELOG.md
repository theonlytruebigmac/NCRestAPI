# Changelog

## 1.9.0

### Added

- **Device Notes**: `Get-NCDeviceNotes`, `New-NCDeviceNote`, `Set-NCDeviceNote`,
  `Remove-NCDeviceNote` — full CRUD for device notes including bulk operations.
- **Custom PSA Tickets**: `New-NCCustomPsaTicket` (create), `Invoke-NCCustomPsaTicket`
  (reopen/resolve). `Get-NCCustomPsaTicket` now supports the credential-free `GET`
  variant in addition to the existing `POST`.
- **Standard PSA**: `Set-NCStandardPsaCustomerMapping` (update mappings),
  `Get-NCStandardPsaCompanies`, `Get-NCStandardPsaContacts`, `Get-NCStandardPsaSites`.
- **Remote Control**: `New-NCRemoteControlTask`, `Get-NCRemoteControlType`.
- **Org Unit Limits**: `Get-NCOrgLimits`, `Set-NCOrgLimits`.
- **User Management**: `New-NCUser` (create user in org unit),
  `Get-NCCurrentUser` (`GET /api/users/me`).
- **Windows Services**: `Invoke-NCDeviceServiceAction` (start/stop/restart).
- **SSO Authentication**: `Connect-NCentral -SsoToken` and `Set-NCRestConfig -SsoToken`
  for identity-provider-based authentication via `POST /api/auth/sso`.
- `Get-NCServerInfo -Time`: `GET /api/server-info/time`.
- `Get-NCApiLinks`: added `-AccessGroups`, `-ScheduledTasks`, `-Users` switches
  for the remaining navigation endpoints.

## 1.8.1

### Fixed

- `Get-NCScheduledTasks`: removed dead `-All`/`-PageNumber`/`-PageSize`/`-SortBy`/`-SortOrder`
  parameters that always threw before being used. `-TaskId` is now mandatory.
- `New-NCOrgAccessGroup` / `New-NCDeviceAccessGroup`: optional `orgUnitIds`/`deviceIds`/`userIds`
  arrays are no longer sent as `null` when omitted.
- `Get-NCStandardPsaCustomerMapping`: migrated from deprecated
  `/api/standard-psa/customer-mapping/{id}` to `/api/standard-psa/customer/{id}/mappings`.
- `Get-NCFilters`, `New-NCServiceOrg`, `New-NCSite`: added `begin`/`process` blocks
  for consistency and correct API instance lifecycle.

### Changed

- Standardized PascalCase variable references in body construction and
  `ShouldProcess` calls across `New-NCCustomer`, `New-NCSite`, `New-NCServiceOrg`,
  `Get-NCJobStatus`, `Get-NCDefaultDeviceProperty`.
- Fixed `.PARAMETER` casing in comment-based help to match parameter declarations
  in `Get-NCDeviceServices`, `Get-NCApplianceTask`, `Get-NCScheduledTaskStatus`,
  `New-NCSite`, `New-NCCustomer`, `New-NCScheduledTask`.
- Cleaned up indentation and removed extra blank lines in `Get-NCJobStatus`,
  `Get-NCDefaultDeviceProperty`, `Get-NCDeviceAssets`, `Get-NCDeviceServices`.
- `SpecDrift.Tests.ps1` now reads root `spec.json` instead of
  `Tests/fixtures/openapi-spec.json`.
- Added test asserting `Get-NCScheduledTasks` requires `-TaskId`.

## 1.8.0

### Fixed (surfaced by a full cmdlet matrix run against demo server)

- Removed 37 redundant `[Alias()]` entries whose value was case-insensitively the
  same as the parameter name (e.g. `[Alias("DeviceId")] [string]$deviceId`).
  PowerShell treats those as duplicate identifiers and throws
  `"alias declared multiple times"` or `"parameter conflicts with the parameter by
  the same name"`. Affected: `Get-NCUserRoles`, `Get-NCDeviceServices`,
  `New-NCCustomer`, `New-NCSite`, `New-NCScheduledTask`, and ~30 others.
- `New-NCScheduledTask`: local `$credential` hashtable was colliding with the
  `[pscredential]$Credential` parameter (PowerShell variable names are
  case-insensitive), so `-WhatIf` threw
  `"Cannot convert Hashtable to PSCredential"`. Renamed the local to `$credBody`.

### Confirmed working against live server

60+ cmdlets exercised with real data. Non-module "failures" documented so they are
not surprising:

- `Get-NCActiveIssues -OrgUnitId 1` returns HTTP 400 because SYSTEM-scope
  active-issues listing is not supported by N-central. Works on any CUSTOMER/SITE
  org-unit.
- `Get-NCRegTokens -OrgUnitId 1` returns HTTP 403 at system scope.
- `Get-NCDefaultOrgProperty` / `Get-NCDefaultDeviceProperty` return 404 when called
  with property IDs that do not exist - use `Get-NCOrgProperty` /
  `Get-NCDeviceProperty` to discover valid IDs first.

## 1.7.0

### Fixed

- **Silent pagination truncation.** Without `-All` the module wasn't sending a
  `pageSize` parameter, so N-central returned its server default of 50 rows. On a
  real tenant with 423 org units / 203 customers / 166 sites, callers were getting
  50 back with no indication anything was missing. Default `pageSize` is now 500
  across every paginated list cmdlet, and `Invoke()` emits
  `Write-Warning "[NCRestAPI] ... returned X of Y items. Pass -All..."` whenever
  the response envelope reports `totalItems > itemCount` outside the paginator.
- `Get-NCUsers`, `Get-NCAccessGroups` were calling `/api/users` and
  `/api/access-groups` - these are hypermedia navigation endpoints that return only
  `_links`, not data. Both now default to the system-level org unit
  (`/api/org-units/1/{users,access-groups}`) when no scope is supplied, matching
  the existing `Get-NCDevices` pattern.
- `Get-NCScheduledTasks` with no `-TaskId` previously called `/api/scheduled-tasks`
  which is also a navigation endpoint. N-central has no bulk-list-all-tasks
  endpoint, so the cmdlet now throws a clear actionable error pointing users to
  `Get-NCDeviceScheduledTasks`.

### Changed

- `Invoke()` logs pagination envelope metadata (`page`, `itemCount`, `totalItems`)
  at verbose level before stripping `.data`.
- Added a `hidden [bool]$InPager` flag on the class so the new truncation warning
  suppresses itself during `Invoke-NCPagedRequest` iteration.

### Verified against a live N-central server

- 188 users, 1 access group, 423 org units, 203 customers, 166 sites all return
  complete counts in default mode.
- Truncation warning fires correctly when `-PageSize` is smaller than total
  (`Get-NCFilters -PageSize 3 returned 3 of 189 items`).
- `Get-NCScheduledTasks` throws the actionable error instead of returning `_links`.
- Pipeline chains (`Get-NCServiceOrgs | Get-NCCustomers`, devices ->
  `Get-NCDeviceScheduledTasks`) work end-to-end.

## 1.6.0

### Reliability

- `Invoke()` now honors `Retry-After` on HTTP 429/5xx. Responses carrying a numeric
  seconds value or HTTP-date are parsed and the retry is delayed accordingly
  (capped at 60 s per attempt). Falls back to exponential backoff when the header
  is absent.

### Security / API surface

- Dropped the legacy parameterless constructor on `NCRestAPI` that read
  `NcentralBaseUrl` / `NcentralApiToken` process environment variables. Nothing
  writes those any more, so the fallback was dead code with a misleading error path.
  The only constructor is now the explicit `NCRestAPI(baseUrl, apiToken, ...)`.
- Added `[ValidateNotNullOrEmpty()]` to every mandatory string parameter across the
  module (38 files touched). Empty strings piped through `ValueFromPipelineByPropertyName`
  are now rejected at parameter-bind time instead of producing a malformed URL.
- `Connect-NCentral` gained `-PassThru` which returns the connection info after
  authenticating.

### Discoverability

- Added `[OutputType([pscustomobject])]` to 32 getter cmdlets so `Get-Help -Full`
  reports the return type and `$result | Get-Member` works in tooling.

### Tests / CI

- New Pester cases: paginator termination on short page, query-string encoding for
  `=`/`&`/space characters, empty-BaseUrl rejection in `Set-NCRestConfig`, and
  `Connect-NCentral -PassThru`. 77 tests total.
- Added `.github/workflows/publish.yml` - runs analyzer + Pester, stages the module
  (drops Tests/ and fixtures/), and publishes to PSGallery on GitHub release
  (`secrets.PSGALLERY_API_KEY`). Supports `workflow_dispatch` dry-run.

## 1.5.0

### Added

- `Get-NCApiLinks` covers the four navigational `_links` endpoints (`/api`,
  `/api/custom-psa`, `/api/custom-psa/tickets`, `/api/standard-psa`) bringing the module
  to 100% path coverage of the OpenAPI spec.
- `Get-NCRestData` is now a full escape hatch supporting `-Method Get|Post|Put|Patch|Delete`
  with `-Body`, covering any endpoint the spec adds later.
- `Get-NCScheduledTasks` now supports `-All` / pagination / pipeline input.
- `Get-NCScheduledTaskStatus` and `Get-NCRegTokens` accept pipeline input
  (`customerId`/`siteId`/`orgUnitId`/`taskId` property names) and route through
  parameter sets.
- PascalCase `[Alias]` decorators on the older camelCase parameters (SoId, CustomerId,
  DeviceId, ContactFirstName, etc.) so pipelines from spec-shaped objects bind cleanly
  without any breaking renames.
- Expanded Pester coverage: body-shape contracts for `Set-NCDeviceProperty`,
  `Set-NCDefaultOrgProperty`, `Update-NCAssetLifecycle`, maintenance-window CRUD,
  the authenticated `/api/server-info/extra/authenticated` POST, and the
  `Get-NCServiceOrgs` SO-vs-customers semantics - 73 tests total.

### Changed

- Dropped the redundant `try { ... } catch { Write-Error ... }` boilerplate from 15
  cmdlets. Errors now propagate as terminating exceptions carrying the HTTP status code
  and response body from `Invoke()`. Callers that want the old non-terminating behavior
  can add `-ErrorAction Continue`.

### Fixed

- `Get-NCScheduledTasks` was typed `[int]$taskid` (spec says string) and had a trailing
  slash on the all-tasks endpoint path.
- `Get-NCScheduledTaskStatus` / `Get-NCRegTokens` / `Get-NCRestData` had dead try-blocks
  with no corresponding catch after a previous cleanup.

## 1.4.0

### Spec alignment

Cross-checked every module endpoint and body against the N-central OpenAPI spec at
`/api-explorer/openapi-spec.json`. The module now covers 55 of the
67 spec paths; the remaining 12 are either internal auth endpoints used by the class
or navigational link endpoints (`/api`, `/api/custom-psa`, `/api/standard-psa`, etc).

### Added

- `Get-NCDeviceScheduledTasks` (`GET /api/devices/{id}/scheduled-tasks`) - tasks assigned
  to a specific device.
- `Get-NCServerInfo -Version` (`GET /api/server-info`) - running API-Service version.
- `Get-NCServerInfo -Extra -Credential ...` (`POST /api/server-info/extra/authenticated`)
  for the authenticated variant.
- `New-NCUserRole` (`POST /api/org-units/{id}/user-roles`).

### Changed

- **Breaking:** `Get-NCServiceOrgs -SoId X` now returns the service-organization itself
  (`GET /api/service-orgs/{id}`). Use `-Customers` to get the old behavior
  (`GET /api/service-orgs/{id}/customers`), or call `Get-NCCustomers -SoId X` which has
  always meant the same thing.
- `Set-NCDeviceProperty` / `Set-NCOrgProperty` now expose all `DeviceCustomPropertyModification`
  and `OrgUnitCustomPropertyModification` body fields (`propertyName`, `propertyType`,
  `enumeratedValueList`) instead of `value` only. Only bound parameters are sent.
- `Set-NCDefaultOrgProperty` body now matches the `DefaultCustomPropertyModifyRequest`
  schema exactly: removed the extraneous `orgUnitId` field (it is already in the path),
  added `enumeratedValueList`, renamed `-Value` -> `-DefaultValue` to match the spec
  field name.
- `Set-NCDeviceProperty` / `Set-NCOrgProperty` / `Set-NCDefaultOrgProperty` / `New-NCCustomer`
  all gained `begin`/`process` pipeline handling.
- `Get-NCServerInfo` parameter set refactored (`-Health`, `-Version`, `-Extra`, plus
  default links mode) so the endpoints are unambiguous.

### Fixed

- `Set-NCDeviceProperty` and `Set-NCOrgProperty` stopped pre-serializing the body with
  `ConvertTo-Json`; the class `Invoke` already handles serialization, and the manual
  call was truncating nested enumerated-value lists at default depth.

## 1.3.0

### Added

- `-All` auto-pagination and pipeline input extended to `Get-NCUsers`, `Get-NCUserRoles`,
  `Get-NCFilters`, `Get-NCActiveIssues`, `Get-NCOrgProperty`, `Get-NCDeviceProperty`.
  Every paginated list cmdlet now supports `-All`.
- `Get-NCOrgProperty -PropertyId` and `Get-NCDeviceProperty -PropertyId` for single-property
  lookups (the module previously only exposed the list endpoints).
- Maintenance-windows CRUD: `New-NCMaintenanceWindows`, `Set-NCMaintenanceWindows`,
  `Remove-NCMaintenanceWindows` (with `-Force`/`-WhatIf`/`-Confirm`).
- Asset lifecycle: `Get-NCAssetLifecycle`, `Set-NCAssetLifecycle` (full PUT),
  `Update-NCAssetLifecycle` (PATCH — only supplied fields are sent).
- Device enrollment: `New-NCDevice` (`POST /api/device`).
- Software installers: `Get-NCSoftwareInstallers`, `New-NCSoftwareDownloadLink`.
- Reports: `Get-NCReport`, `New-NCPatchComparisonReport`.
- PSA: `Get-NCStandardPsaCustomerMapping`, `Test-NCStandardPsaCredential`,
  `Get-NCCustomPsaTicket` (all take a `PSCredential` for PSA credentials rather than
  plain strings).
- Class gains `Delete(endpoint, body)` and `Patch(endpoint, body)` overloads.
- New spec-drift test (`Tests/SpecDrift.Tests.ps1`) asserts every endpoint literal in
  the module is still present in the bundled OpenAPI fixture at
  `Tests/fixtures/openapi-spec.json`. A nightly CI job refreshes the fixture from the
  live demo server so drift surfaces automatically.

## 1.2.0

### Added

- Pipeline input (`ValueFromPipelineByPropertyName`) on `Get-NCDevices`, `Get-NCCustomers`,
  `Get-NCSites`, `Get-NCOrgUnits`, `Get-NCServiceOrgs`, `Get-NCAccessGroups`, plus the device
  / org-unit by-id accessors. `Get-NCServiceOrgs | Get-NCCustomers | Get-NCSites` now works.
- `-All` auto-pagination switch on `Get-NCDevices`, `Get-NCCustomers`, `Get-NCSites`,
  `Get-NCOrgUnits`, `Get-NCServiceOrgs`, `Get-NCAccessGroups`.
- `Remove-NCDevice` (`DELETE /api/devices/{id}`) with `SupportsShouldProcess`.
- `Get-NCDeviceActivationKey` (`GET /api/devices/{id}/activation-key`).
- `Get-NCDeviceMaintenanceWindows` (`GET /api/devices/{id}/maintenance-windows`).
- `SupportsShouldProcess` plus proper `ShouldProcess` guards on all `New-NC*` and `Set-NC*`
  cmdlets; `-WhatIf` and `-Confirm` now work as expected.
- Pester coverage for pagination, pipeline binding, and `-WhatIf` / `-Force` semantics.

### Notes

- `ConfirmImpact='High'` on `Remove-NCDevice` means it will prompt by default unless
  `-Force` is supplied or `$ConfirmPreference` is lowered.

## 1.1.0

### Security

- Tokens are now held as `SecureString` in memory only; the Base64 "encryption" prefix scheme and
  process-env-var persistence are gone. `SecureStringToBSTR` buffers are zeroed after reveal.
- Verbose logging scrubs `access`, `refresh`, and `api` JWT fields — not just `Bearer` headers.

### Correctness

- HTTP calls funnel through a single `Invoke()` with exponential-backoff retry on 429/5xx, a 60 s
  timeout, and rich error propagation (status code + `ErrorDetails.Message`) instead of silent `$null`.
- `Get-NCDevices` no longer drops pagination / sort parameters when called without an ID.
- `Get-NCSites` corrected `if` -> `elseif` so `-siteId` is not overwritten.
- `Get-NCServiceOrgs`: removed undefined `$Select` reference; corrected error message.
- `Get-NCUsers`: added `[CmdletBinding()]`; corrected error message.
- `New-NCScheduledTask`: plain `-username`/`-password` replaced with `[pscredential]$Credential`;
  added the missing `-parameters` parameter.
- Typos fixed in `Get-NCDeviceAssets`, `Get-NCDeviceServices`, `Get-NCScheduledTasks`,
  `Set-NCDeviceProperty`, `Set-NCDefaultOrgProperty`.
- Query strings are URL-encoded via shared `ConvertTo-NCQueryString` helper.
- Path-parameter ID types audited against the N-central OpenAPI spec; values that the spec
  permits as either integer or string (deviceId, orgUnitId, customerId, siteId, soId,
  propertyId, taskId, accessGroupId, userRoleId) are now typed `[string]` to avoid int32
  overflow and accept whatever format a given endpoint returns.

### API

- New `Connect-NCentral` / `Disconnect-NCentral` aliases following PowerShell convention.
- New `-All` switch on `Get-NCDevices` for auto-pagination.
- New `Invoke-NCPagedRequest` internal helper.
- `Get-NCRestApiInfo` returns a sanitized object (no raw tokens); `-Kill` clears both module-scope
  and global instance references.

### Module hygiene

- `FunctionsToExport` is now an explicit list; `PowerShellVersion = '5.1'`,
  `CompatiblePSEditions = @('Desktop', 'Core')`.
- Removed empty stub files `Get-NCCustomPSATicket.ps1` and `Test-PSACredentials.ps1`.
- Added PSScriptAnalyzer settings, Pester 5 test suite, and GitHub Actions CI
  (ubuntu/windows/macos matrix).

### Breaking changes

- ID path parameters previously typed `[int]` are now `[string]`. Scripts that were passing
  integers continue to work (PowerShell implicitly converts), but strictly-typed pipelines may
  need adjustment.
- `Get-NCRestApiInfo` (without `-Kill`) now returns a property bag instead of the raw instance.
  Use `Get-NCRestApiInstance` if you need the live object.
- Tokens are no longer written to process environment variables. Callers that read
  `$env:NcentralAccessToken` will not find one.
