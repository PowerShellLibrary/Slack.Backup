Clear-Host
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
Import-Module -Name Pester -Force
Import-Module .\Slack.Backup\Slack.Backup.psm1 -Force

Describe 'Test-Auth' {
    Context "Check token" {
        Mock Invoke-SlackAPI -ModuleName Slack.Backup {
            if ($Method -eq 'auth.test') {
                $file = "auth.test.error.json"
                if ($Token -eq "valid") {
                    $file = "auth.test.ok.json"
                }
                Get-Content ".\Tests\MockData\$file" | ConvertFrom-Json
            }
        }

        It "Given -Token '<Token>', it returns '<Expected>'" -TestCases @(
            @{ Token = "invalid"; Expected = $false }
            @{ Token = "valid"; Expected = $true }
        ) {
            param ($Token, $Expected)
            Test-Auth -Token $Token -ErrorAction SilentlyContinue | Should -Be $Expected
        }
    }
}