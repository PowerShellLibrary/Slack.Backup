Import-Module PSScriptAnalyzer

$Public = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.ps1" | ? { $_.Name[0].Equals($_.Name.ToUpper()[0]) }

$Public | % { Invoke-ScriptAnalyzer -Path $_.fullname -Settings .\PSScriptAnalyzerSettings.ps1 }