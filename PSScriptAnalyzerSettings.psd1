@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions',
        # Intentional: Set-NCRestConfig mirrors the instance to $global: so scripts
        # dot-sourcing module files without loading the module can still reach it.
        'PSAvoidGlobalVars',
        'PSUseSingularNouns',
        'PSUseBOMForUnicodeEncodedFile',
        # Tests materialize dummy credentials; production code handles them via [pscredential].
        'PSAvoidUsingConvertToSecureStringWithPlainText'
    )
}
