function Invoke-FileProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackFile
    )
    process {
        Get-PipelineProcessor -Name Invoke-FileProcessor* -Parameters @( @{Name = "SlackFile"; Type = "Object" } ) | % {
            Write-Verbose "Invoking processor: $($_.Name)"
            $SlackFile = &($_.Name) -SlackFile $SlackFile
        }
        $SlackFile
    }
}