function Invoke-FileDataProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [byte[]]$SlackFile
    )
    process {
        Get-PipelineProcessor -Name Invoke-FileDataProcessor* -Parameters @( @{Name = "SlackFile"; Type = [byte[]] } ) | % {
            Write-Verbose "Invoking processor: $($_.Name)"
            $SlackFile = &($_.Name) -SlackFile $SlackFile
        }
        $SlackFile
    }
}