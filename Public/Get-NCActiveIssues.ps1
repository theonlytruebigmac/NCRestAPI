<#
.SYNOPSIS
Retrieves active issues for an org unit from the N-central API.

.DESCRIPTION
Calls `/api/org-units/{orgUnitId}/active-issues`. Supports `-All` and pipeline input.

.EXAMPLE
Get-NCOrgUnits -All | Get-NCActiveIssues -All
#>
function Get-NCActiveIssues {
    [CmdletBinding(DefaultParameterSetName = 'Page')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgUnitId,

        [int]$FilterId,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageNumber,

        [Parameter(ParameterSetName = 'Page')]
        [int]$PageSize,

        [string]$Select,
        [string]$SortBy,
        [ValidateSet('asc', 'desc')]
        [string]$SortOrder = 'asc'
    )

    begin { $api = Get-NCRestApiInstance }

    process {
        $endpoint = "api/org-units/$OrgUnitId/active-issues"

        $queryParameters = @{}
        Add-NCCommonQuery -Parameters $queryParameters -FilterId $FilterId -Select $Select -SortBy $SortBy -SortOrder $SortOrder

        if ($All) {
            return Invoke-NCPagedRequest -Endpoint $endpoint -QueryParameters $queryParameters
        }

        if ($PageNumber) { $queryParameters['pageNumber'] = $PageNumber }


        if ($PageSize)   { $queryParameters['pageSize']   = $PageSize } else { $queryParameters['pageSize'] = 500 }

        $endpoint += ConvertTo-NCQueryString -Parameters $queryParameters
        Write-Verbose "[FUNCTION] Get-NCActiveIssues: $endpoint"
        $api.Get($endpoint)
    }
}
