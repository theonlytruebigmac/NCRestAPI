$script:NCRestApiInstance = $null

$privateFiles = @(Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 -ErrorAction SilentlyContinue)
foreach ($file in $privateFiles) { . $file.FullName }

$publicFiles = @(Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 -ErrorAction SilentlyContinue)
foreach ($file in $publicFiles) { . $file.FullName }

Export-ModuleMember -Function $publicFiles.BaseName
