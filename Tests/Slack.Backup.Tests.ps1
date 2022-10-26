Clear-Host
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
Import-Module -Name Pester -Force
Import-Module .\Slack.Backup\Slack.Backup.psm1 -Force

$script:processorInvoked = $false

function Invoke-FileDataProcessorMock {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [byte[]]$SlackFile,
        [Parameter(Mandatory = $true, Position = 1 )]
        [System.Object]$Metadata
    )
    $script:processorInvoked = $true
    $SlackFile
}

function Invoke-FileProcessorMock {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackFile
    )
    $script:processorInvoked = $true
    $SlackFile
}

function Invoke-MessageProcessorMock {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackMessage
    )
    $script:processorInvoked = $true
    $SlackMessage
}

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

Describe 'Pipelines' {
    Context "Invoke-FileProcessingPipeline" {
        BeforeEach {
            Mock Get-FilesList { Get-Content .\Tests\MockData\files.list.json | ConvertFrom-Json }
            Mock Get-SlackFile { return [byte[]]::new(12) }
        }

        It "valid mock: Get-FilesList" {
            $files = Get-FilesList -Token "fake" -ChannelId "fake"
            $files | Should -Not -BeNullOrEmpty
            $files.ok | Should -BeTrue
            foreach ($f in $files | Select-Object -ExpandProperty files) {
                $f.url_private | Should -Not -BeNullOrEmpty
            }
        }

        It "valid mock: Get-SlackFile" {
            $file = Get-SlackFile -Token "fake" -Uri "fake"
            $file -is [System.Object[]] | Should -BeTrue
            $file.Length | Should -BeExactly 12
        }

        It "should invoke Invoke-FileDataProcessingPipeline" {
            try {
                New-Alias -Name 'Invoke-FileDataProcessorEncryption' -Value 'Invoke-FileDataProcessorMock' -Scope Global
                $script:processorInvoked = 0
                Invoke-BackupJob -Token "fake" -Location ".\Tests\Output"-Files
            }
            finally {
                Remove-Item 'Alias:\Invoke-FileDataProcessorEncryption' -Force
            }
            $script:processorInvoked | Should -BeTrue
        }

        It "should invoke Invoke-FileProcessingPipeline" {
            try {
                New-Alias -Name 'Invoke-FileProcessorEncryption' -Value 'Invoke-FileProcessorMock' -Scope Global
                $script:processorInvoked = 0
                Invoke-BackupJob -Token "fake" -Location ".\Tests\Output"-Files
            }
            finally {
                Remove-Item 'Alias:\Invoke-FileProcessorEncryption' -Force
            }
            $script:processorInvoked | Should -BeTrue
        }
    }

    Context "Invoke-MessageProcessingPipeline" {
        BeforeEach {
            Mock Get-Channel { Get-Content .\Tests\MockData\conversations.list.json | ConvertFrom-Json }
            Mock Get-FullHistory { Get-Content .\Tests\MockData\conversations.history.json | ConvertFrom-Json  | Select-Object -ExpandProperty messages }
        }

        It "valid mock: Get-Channel" {
            $channels = Get-Channel -Token "fake"
            $channels | Should -Not -BeNullOrEmpty
            $channels.ok | Should -BeTrue
            foreach ($c in $channels | Select-Object -ExpandProperty channels) {
                $c.id | Should -Not -BeNullOrEmpty
            }
        }

        It "valid mock: Get-FullHistory" {
            $messages = Get-FullHistory -Token "fake" -ChannelId "fake" -Start "fake"
            $messages -is [System.Object[]] | Should -BeTrue
        }

        It "should Invoke-MessageProcessingPipeline" {
            try {
                New-Alias -Name 'Invoke-MessageProcessorEncryption' -Value 'Invoke-MessageProcessorMock' -Scope Global
                $script:processorInvoked = 0
                Invoke-BackupJob -Token "fake" -Location ".\Tests\Output" -Channels
            }
            finally {
                Remove-Item 'Alias:\Invoke-MessageProcessorEncryption' -Force
            }
            $script:processorInvoked | Should -BeTrue
        }
    }
}