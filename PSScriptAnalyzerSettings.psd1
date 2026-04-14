@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSAvoidGlobalVars',
        'PSUseSingularNouns',
        'PSUseBOMForUnicodeEncodedFile',
        # Tests materialize dummy credentials; production code handles them via [pscredential].
        'PSAvoidUsingConvertToSecureStringWithPlainText'
    )
}
