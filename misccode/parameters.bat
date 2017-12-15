:: If a second parameter is passed, use it instead.

:: One parameter is passed:
if '%2'=='' start winword.exe %1
:: Two parameters are passed:
if not '%2'=='' start winword.exe %2
