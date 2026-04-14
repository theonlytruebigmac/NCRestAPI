<#
.SYNOPSIS
Escape hatch for raw N-central API calls the module doesn't wrap yet.

.DESCRIPTION
Forwards any endpoint + method + body to the underlying NCRestAPI client. Handy for
endpoints that are not yet covered by a dedicated cmdlet (e.g. navigational `_links`
endpoints, new endpoints added to the API after a module release).

.PARAMETER Endpoint
The endpoint to call (e.g. `api/customers`, `api/custom-psa/tickets`).

.PARAMETER Method
HTTP verb. Defaults to `Get`.

.PARAMETER Body
Optional body for POST/PUT/PATCH/DELETE. Hashtable or PSCustomObject - the class
serializes to JSON automatically.

.EXAMPLE
Get-NCRestData -Endpoint 'api/custom-psa'

.EXAMPLE
Get-NCRestData -Endpoint 'api/some-new-endpoint' -Method Post -Body @{ foo = 'bar' }
#>
function Get-NCRestData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,

        [ValidateSet('Get', 'Post', 'Put', 'Patch', 'Delete')]
        [string]$Method = 'Get',

        [object]$Body
    )
    $api = Get-NCRestApiInstance
    Write-Verbose "[FUNCTION] Get-NCRestData: $Method $Endpoint"
    switch ($Method) {
        'Get'    { return $api.Get($Endpoint) }
        'Post'   { return $api.Post($Endpoint, $Body) }
        'Put'    { return $api.Put($Endpoint, $Body) }
        'Patch'  { return $api.Patch($Endpoint, $Body) }
        'Delete' {
            if ($PSBoundParameters.ContainsKey('Body')) { return $api.Delete($Endpoint, $Body) }
            return $api.Delete($Endpoint)
        }
    }
}
