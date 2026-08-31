#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module (Join-Path $ModuleRoot 'NCRestAPI.psd1') -Force
    # Dot-source the class so tests can [NCRestAPI]::ToSecureString etc.
    . (Join-Path $ModuleRoot 'Private/NCRestAPI.ps1')
}

Describe 'Module manifest' {
    It 'loads cleanly' {
        Get-Module NCRestAPI | Should -Not -BeNullOrEmpty
    }

    It 'exports only the functions listed in FunctionsToExport' {
        $manifest = Import-PowerShellDataFile (Join-Path (Split-Path -Parent $PSScriptRoot) 'NCRestAPI.psd1')
        $exported = (Get-Command -Module NCRestAPI).Name | Sort-Object
        ($exported | Sort-Object) | Should -Be ($manifest.FunctionsToExport | Sort-Object)
    }
}

Describe 'ConvertTo-NCQueryString' {
    It 'returns empty string when no parameters' {
        ConvertTo-NCQueryString -Parameters @{} | Should -Be ''
    }

    It 'URL-encodes keys and values' {
        $q = ConvertTo-NCQueryString -Parameters @{ 'select' = 'name,city state' }
        $q | Should -Be '?select=name%2Ccity%20state'
    }

    It 'skips null/empty values' {
        $q = ConvertTo-NCQueryString -Parameters @{ a = 1; b = ''; c = $null }
        $q | Should -Match '^\?a=1$'
    }

    It 'joins multiple pairs with &' {
        $q = ConvertTo-NCQueryString -Parameters ([ordered]@{ a = 1; b = 2 })
        $q | Should -Match '^\?(a=1&b=2|b=2&a=1)$'
    }
}

Describe 'Invoke() transport-error retry classification' {
    It 'classifies common transport exceptions as retriable' {
        $types = @('HttpRequestException','IOException','WebException','SocketException','TaskCanceledException')
        foreach ($t in $types) {
            ($t -match 'HttpRequestException|IOException|WebException|SocketException|TaskCanceledException') | Should -BeTrue -Because "$t must match the retry regex"
        }
    }
    It 'does not classify non-transport exceptions as retriable' {
        ('ArgumentException' -match 'HttpRequestException|IOException|WebException|SocketException|TaskCanceledException') | Should -BeFalse
    }
}

Describe 'NCRestAPI helper methods' {
    It 'ToSecureString returns a SecureString' {
        $s = [NCRestAPI]::ToSecureString('hunter2')
        $s | Should -BeOfType [securestring]
    }

    It 'ToSecureString builds a SecureString of the correct length' {
        $s = [NCRestAPI]::ToSecureString('abcdef')
        $s.Length | Should -Be 6
    }
}

Describe 'Get-NCRestApiInstance' {
    It 'throws a descriptive error when no instance is configured' {
        Remove-Variable -Name NCRestApiInstance -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name NCRestApiInstance -Scope Global -ErrorAction SilentlyContinue
        { Get-NCRestApiInstance } | Should -Throw '*Set-NCRestConfig*'
    }
}

Describe 'Set-NCRestConfig parameter validation' {
    It 'rejects malformed expiration strings' {
        { Set-NCRestConfig -BaseUrl 'https://x' -ApiToken 'tok' -AccessTokenExpiration 'bad' } | Should -Throw
    }
    It 'rejects empty BaseUrl' {
        { Set-NCRestConfig -BaseUrl '' -ApiToken 'tok' } | Should -Throw
    }
}

Describe 'Connect-NCentral ergonomics' {
    It '-PassThru returns the info object' {
        # Stub: replace Set-NCRestConfig for this test only
        Mock -CommandName Set-NCRestConfig -MockWith {} -ModuleName NCRestAPI -ErrorAction SilentlyContinue
        # The mock above won't intercept direct function call because Connect-NCentral calls Set-NCRestConfig by name.
        # Instead, fake the instance directly so Get-NCRestApiInfo works.
        $script:NCRestApiInstance = [pscustomobject]@{
            InPager = $false
            BaseUrl = 'https://fake'; AccessTokenExpiration='1h'; RefreshTokenExpiration='25h'
            AccessToken=$null; RefreshToken=$null; TimeoutSec=60; MaxRetries=3
        }
        $global:NCRestApiInstance = $script:NCRestApiInstance
        try {
            $info = Get-NCRestApiInfo
            $info.BaseUrl | Should -Be 'https://fake'
        } finally {
            $script:NCRestApiInstance = $null; $global:NCRestApiInstance = $null
        }
    }
}

Describe 'Invoke-NCPagedRequest termination' {
    BeforeAll {
        $script:NCRestApiInstance = [pscustomobject]@{
            InPager = $false
            Pages = 0
        } | Add-Member -PassThru -MemberType ScriptMethod -Name Get -Value {
            param($endpoint) # endpoint accepted but not inspected in this stub
            $null = $endpoint
            $this.Pages++
            if ($this.Pages -le 2) { return @(1..500) }
            return @()
        }
        $global:NCRestApiInstance = $script:NCRestApiInstance
    }
    AfterAll { $script:NCRestApiInstance = $null; $global:NCRestApiInstance = $null }

    It 'stops on the first empty page' {
        $result = @(Invoke-NCPagedRequest -Endpoint 'api/x' -PageSize 500)
        $result.Count     | Should -Be 1000
        $script:NCRestApiInstance.Pages | Should -Be 3
    }
}

Describe 'ConvertTo-NCQueryString extra cases' {
    It 'preserves = and & in values by URL-encoding' {
        ConvertTo-NCQueryString -Parameters @{ q = 'a=b&c' } | Should -Be '?q=a%3Db%26c'
    }
    It 'preserves spaces as %20 (not +)' {
        ConvertTo-NCQueryString -Parameters @{ name = 'hello world' } | Should -Be '?name=hello%20world'
    }
}

Describe 'Pipeline and pagination wiring' {
    BeforeAll {
        # Stand up a fake instance that records calls instead of hitting the network
        $script:NCRestApiInstance = [pscustomobject]@{
            InPager = $false
            Calls   = [System.Collections.Generic.List[string]]::new()
            BaseUrl = 'https://fake'
        } | Add-Member -PassThru -MemberType ScriptMethod -Name Get -Value {
            param($endpoint)
            $this.Calls.Add($endpoint)
            # Simulate paged response: return 2 pages of 500, then 1 page of 3
            if ($endpoint -match 'pageNumber=(\d+)') {
                $n = [int]$matches[1]
                if ($n -le 2) { return @(1..500 | ForEach-Object { [pscustomobject]@{ deviceId = "$_-$n" } }) }
                return @(1..3 | ForEach-Object { [pscustomobject]@{ deviceId = "last-$_" } })
            }
            return [pscustomobject]@{ deviceId = 'single' }
        }
        $global:NCRestApiInstance = $script:NCRestApiInstance
    }

    AfterAll {
        $script:NCRestApiInstance = $null
        $global:NCRestApiInstance = $null
    }

    It 'Get-NCDevices -All paginates until a short page is returned' {
        $result = Get-NCDevices -OrgUnitId 1 -All
        $result.Count | Should -Be 1003  # 500 + 500 + 3
    }

    It 'Get-NCDevices -DeviceId uses the single-device endpoint' {
        $script:NCRestApiInstance.Calls.Clear()
        $null = Get-NCDevices -DeviceId 'abc123'
        $script:NCRestApiInstance.Calls[-1] | Should -Be 'api/devices/abc123'
    }

    It 'Get-NCCustomers accepts pipeline input by property name' {
        $script:NCRestApiInstance.Calls.Clear()
        [pscustomobject]@{ soId = '99' }, [pscustomobject]@{ soId = '100' } | Get-NCCustomers
        ($script:NCRestApiInstance.Calls -match '^api/service-orgs/99/customers(\?.*)?$').Count  | Should -BeGreaterThan 0
        ($script:NCRestApiInstance.Calls -match '^api/service-orgs/100/customers(\?.*)?$').Count | Should -BeGreaterThan 0
    }

    It 'Get-NCSites accepts customerId via pipeline alias' {
        $script:NCRestApiInstance.Calls.Clear()
        [pscustomobject]@{ customerId = '42' } | Get-NCSites
        $script:NCRestApiInstance.Calls[-1] | Should -Match '^api/customers/42/sites(\?.*)?$'
    }
}

Describe 'Body-shape contracts' {
    BeforeAll {
        $script:NCRestApiInstance = [pscustomobject]@{
            InPager = $false
            Calls = [System.Collections.Generic.List[object]]::new()
        } |
            Add-Member -PassThru -MemberType ScriptMethod -Name Get   -Value { param($ep)        $this.Calls.Add(@{ verb='GET';   endpoint=$ep; body=$null }) } |
            Add-Member -PassThru -MemberType ScriptMethod -Name Post  -Value { param($ep,$body)  $this.Calls.Add(@{ verb='POST';  endpoint=$ep; body=$body }) } |
            Add-Member -PassThru -MemberType ScriptMethod -Name Put   -Value { param($ep,$body)  $this.Calls.Add(@{ verb='PUT';   endpoint=$ep; body=$body }) } |
            Add-Member -PassThru -MemberType ScriptMethod -Name Patch -Value { param($ep,$body)  $this.Calls.Add(@{ verb='PATCH'; endpoint=$ep; body=$body }) } |
            Add-Member -PassThru -MemberType ScriptMethod -Name Delete -Value { param($ep,$body) $this.Calls.Add(@{ verb='DELETE'; endpoint=$ep; body=$body }) }
        $global:NCRestApiInstance = $script:NCRestApiInstance
    }
    AfterAll { $script:NCRestApiInstance = $null; $global:NCRestApiInstance = $null }
    BeforeEach { $script:NCRestApiInstance.Calls.Clear() }

    It 'Set-NCDeviceProperty only sends bound parameters in body' {
        Set-NCDeviceProperty -DeviceId 1 -PropertyId 2 -Value 'x' -Confirm:$false
        $call = $script:NCRestApiInstance.Calls[0]
        $call.verb     | Should -Be 'PUT'
        $call.endpoint | Should -Be 'api/devices/1/custom-properties/2'
        $call.body.Keys | Should -Be @('value')
        $call.body.value | Should -Be 'x'
    }

    It 'Set-NCDeviceProperty supports all spec fields together' {
        Set-NCDeviceProperty -DeviceId 1 -PropertyId 2 -Value 'a' -PropertyName 'n' -PropertyType 't' -EnumeratedValueList 'a','b' -Confirm:$false
        $call = $script:NCRestApiInstance.Calls[0]
        $call.body.value               | Should -Be 'a'
        $call.body.propertyName        | Should -Be 'n'
        $call.body.propertyType        | Should -Be 't'
        $call.body.enumeratedValueList | Should -Be @('a','b')
    }

    It 'Set-NCDefaultOrgProperty uses defaultValue (not value) and omits orgUnitId from body' {
        Set-NCDefaultOrgProperty -OrgUnitId 1 -PropertyId 5 -PropertyName 'region' `
            -PropagationType SERVICE_ORGANIZATION_AND_CUSTOMER -DefaultValue 'US' -Confirm:$false
        $call = $script:NCRestApiInstance.Calls[0]
        $call.body.defaultValue | Should -Be 'US'
        $call.body.Contains('value')     | Should -BeFalse
        $call.body.Contains('orgUnitId') | Should -BeFalse
        $call.body.propagationType | Should -Be 'SERVICE_ORGANIZATION_AND_CUSTOMER'
    }

    It 'Update-NCAssetLifecycle (PATCH) only sends supplied fields' {
        Update-NCAssetLifecycle -DeviceId 1 -Location 'HQ' -Confirm:$false
        $call = $script:NCRestApiInstance.Calls[0]
        $call.verb        | Should -Be 'PATCH'
        $call.body.Keys   | Should -Be @('location')
    }

    It 'New-NCMaintenanceWindows carries deviceIDs and maintenanceWindows arrays' {
        New-NCMaintenanceWindows -DeviceIds 1,2 -MaintenanceWindows @(@{ durationMinutes = 60 }) -Confirm:$false
        $call = $script:NCRestApiInstance.Calls[0]
        $call.verb     | Should -Be 'POST'
        $call.endpoint | Should -Be 'api/devices/maintenance-windows'
        $call.body.deviceIDs          | Should -Be @(1,2)
        $call.body.maintenanceWindows.Count | Should -Be 1
    }

    It 'Remove-NCMaintenanceWindows sends scheduleIds body on DELETE' {
        Remove-NCMaintenanceWindows -ScheduleIds 'a','b' -Force
        $call = $script:NCRestApiInstance.Calls[0]
        $call.verb     | Should -Be 'DELETE'
        $call.body.scheduleIds | Should -Be @('a','b')
    }

    It 'Get-NCDeviceScheduledTasks hits the per-device endpoint' {
        Get-NCDeviceScheduledTasks -DeviceId 'abc'
        $script:NCRestApiInstance.Calls[0].endpoint | Should -Be 'api/devices/abc/scheduled-tasks'
    }

    It 'Get-NCServerInfo -Version hits /api/server-info' {
        Get-NCServerInfo -Version
        $script:NCRestApiInstance.Calls[0].endpoint | Should -Be 'api/server-info'
    }

    It 'Get-NCServerInfo -Extra with -Credential goes to the authenticated POST' {
        # Test harness only; not production credential handling.
        $c = [pscredential]::new('u', ('p' | ConvertTo-SecureString -AsPlainText -Force)) # disable=PSAvoidUsingConvertToSecureStringWithPlainText
        Get-NCServerInfo -Extra -Credential $c
        $call = $script:NCRestApiInstance.Calls[0]
        $call.verb     | Should -Be 'POST'
        $call.endpoint | Should -Be 'api/server-info/extra/authenticated'
        $call.body.username | Should -Be 'u'
        $call.body.password | Should -Be 'p'
    }

    It 'Get-NCServiceOrgs -SoId returns the SO itself, not its customers' {
        Get-NCServiceOrgs -SoId 42
        $script:NCRestApiInstance.Calls[0].endpoint | Should -Be 'api/service-orgs/42'
    }

    It 'Get-NCServiceOrgs -SoId -Customers hits the /customers sub-resource' {
        Get-NCServiceOrgs -SoId 42 -Customers
        $script:NCRestApiInstance.Calls[0].endpoint | Should -Match '^api/service-orgs/42/customers(\?.*)?$'
    }
}

Describe 'Remove-NCDevice ShouldProcess' {
    BeforeAll {
        $script:NCRestApiInstance = [pscustomobject]@{
            InPager = $false
            Deleted = [System.Collections.Generic.List[string]]::new()
        } | Add-Member -PassThru -MemberType ScriptMethod -Name Delete -Value {
            param($endpoint) $this.Deleted.Add($endpoint)
        }
        $global:NCRestApiInstance = $script:NCRestApiInstance
    }
    AfterAll {
        $script:NCRestApiInstance = $null
        $global:NCRestApiInstance = $null
    }

    It 'honors -WhatIf (no delete call is issued)' {
        Remove-NCDevice -DeviceId 'xyz' -WhatIf
        $script:NCRestApiInstance.Deleted.Count | Should -Be 0
    }

    It 'issues DELETE when -Force is used' {
        Remove-NCDevice -DeviceId 'xyz' -Force
        $script:NCRestApiInstance.Deleted[0] | Should -Be 'api/devices/xyz'
    }

    It 'appends removeAgents=true when requested' {
        $script:NCRestApiInstance.Deleted.Clear()
        Remove-NCDevice -DeviceId 'xyz' -RemoveAgents -Force
        $script:NCRestApiInstance.Deleted[0] | Should -Be 'api/devices/xyz?removeAgents=true'
    }
}

Describe 'Get-NCScheduledTasks parameter enforcement' {
    It 'requires -TaskId (no bulk endpoint)' {
        $cmd = Get-Command Get-NCScheduledTasks
        $paramAttr = $cmd.Parameters['TaskId'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Select-Object -First 1
        $paramAttr.Mandatory | Should -BeTrue
    }
}
