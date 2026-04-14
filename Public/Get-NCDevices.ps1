<#
.SYNOPSIS
Retrieves devices from the N-central API.

.DESCRIPTION
Supports retrieving a single device, devices under an org unit, or all devices (defaults to
org-unit 1 - system level). Optional parameters allow filtering, pagination, sorting, and
selecting specific fields.

.PARAMETER OrgUnitId
Org unit to list devices under.

.PARAMETER DeviceId
Specific device to retrieve.

.PARAMETER FilterId
Filter to apply.

.PARAMETER PageNumber
Pagination: page to retrieve.

.PARAMETER PageSize
Pagination: items per page.

.PARAMETER Select
Fields to include in the response.

.PARAMETER SortBy
Field to sort on.

.PARAMETER SortOrder
'asc' (default) or 'desc'.

.EXAMPLE
Get-NCDevices -OrgUnitId 123 -PageSize 50 -SortBy deviceName -SortOrder desc

.NOTES
Author: Zach Frazier
#>
function Get-NCDevices {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OrgUnitId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DeviceId,

        [int]$FilterId,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [string]$Select,
        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        if ($DeviceId) {
            Write-Verbose "[FUNCTION] Get-NCDevices: api/devices/$DeviceId"
            return $api.Get("api/devices/$DeviceId")
        }

        # Default to /api/devices (flat list scoped by the caller's permissions).
        # Use the org-unit-scoped endpoint only when an explicit -OrgUnitId was supplied.
        $endpoint = if ($OrgUnitId) { "api/org-units/$OrgUnitId/devices" } else { 'api/devices' }

        $queryParams = @{}
        Add-NCCommonQuery -Parameters $queryParams -FilterId $FilterId -Select $Select -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            Write-Verbose "[FUNCTION] Get-NCDevices: paging $endpoint"
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParams
        }

        if ($PageNumber) { $queryParams['pageNumber'] = $PageNumber }
        if ($PageSize)   { $queryParams['pageSize']   = $PageSize } else { $queryParams['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParams
        Write-Verbose "[FUNCTION] Get-NCDevices: $endpoint"
        $api.Get($endpoint)
    }
}
