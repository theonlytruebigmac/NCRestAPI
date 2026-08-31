#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
Asserts that every endpoint the module calls still exists in the bundled OpenAPI spec.
Uses the root spec.json as the single source of truth.

The intent is to catch drift, not to enforce coverage: it is fine for the spec to have
endpoints the module doesn't wrap yet.
#>

# Discovery-time data: gather every `"api/..."` literal across public files plus
# the full spec path list, then compare.

$ModuleRoot = Split-Path -Parent $PSScriptRoot
$specPath = Join-Path $ModuleRoot 'spec.json'
if (-not (Test-Path $specPath)) {
    $specPath = Join-Path $PSScriptRoot 'fixtures/openapi-spec.json'
}
$spec = Get-Content $specPath -Raw | ConvertFrom-Json
$specPaths = @($spec.paths.PSObject.Properties.Name)
$specNormalized = $specPaths | ForEach-Object { ($_ -replace '\{[^}]+\}', '{id}') } | Sort-Object -Unique

$endpoints = @{}
foreach ($f in Get-ChildItem -Path (Join-Path $ModuleRoot 'Public') -Filter *.ps1) {
    $src = Get-Content $f.FullName -Raw
    foreach ($m in [regex]::Matches($src, '"(api/[^"\s]+?)"')) {
        $raw = $m.Groups[1].Value
        $norm = '/' + ($raw -replace '\$\w+', '{id}').TrimEnd('/?&')
        $norm = ($norm -split '\?')[0]
        if (-not $endpoints.ContainsKey($norm)) { $endpoints[$norm] = $f.Name }
    }
}

$cases = $endpoints.GetEnumerator() | ForEach-Object {
    @{ Norm = $_.Key; Source = $_.Value; SpecPaths = $specNormalized }
}

Describe 'OpenAPI spec drift' {
    It 'endpoint <Norm> (from <Source>) exists in spec' -ForEach $cases {
        $SpecPaths | Should -Contain $Norm -Because "endpoint used in $Source not present in OpenAPI spec"
    }
}
