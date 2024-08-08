# Ensure compatible PowerShell version
# Requires -Version 7.4.4

# Import Private Functions and Classes
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Import Public Functions
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Declare a global variable for NCRestAPI instance
$global:NCRestApiInstance = $null

# Export Public Functions
Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 | ForEach-Object { $_.BaseName })