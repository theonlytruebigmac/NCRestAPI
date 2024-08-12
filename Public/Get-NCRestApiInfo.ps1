function Get-NCRestApiInfo {
    param (
        [switch]$kill
    )

    if (-not $global:NCRestApiInstance) {
        Write-Error "NCRestAPI instance is not initialized. Please run Set-NCRestConfig first."
        return
    }

    $api = $global:NCRestApiInstance

    if ($kill) {
        $api.Dispose()
        Write-Output "NCRestAPI instance has been disposed."
    } else {
        return $api
    }
}