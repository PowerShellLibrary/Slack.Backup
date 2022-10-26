function Invoke-FileDataProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [byte[]]$SlackFile,
        [Parameter(Mandatory = $true, Position = 1 )]
        [System.Object]$Metadata
    )
    process {
        Get-PipelineProcessor -Name Invoke-FileDataProcessor* -Parameters @( @{Name = "SlackFile"; Type = [byte[]] } ) | % {
            Write-Verbose "Invoking processor: $($_.Name)"
            $SlackFile = &($_.Name) -SlackFile $SlackFile -Metadata $Metadata
        }
        $SlackFile
    }
}