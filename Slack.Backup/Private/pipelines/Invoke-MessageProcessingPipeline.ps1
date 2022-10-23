function Invoke-MessageProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackMessage
    )
    process {
        Get-PipelineProcessor -Name Invoke-MessageProcessor* -Parameters @( @{Name = "SlackMessage"; Type = "Object" } ) | % {
            Write-Verbose "Invoking processor: $($_.Name)"
            $SlackMessage = &($_.Name) -SlackMessage $SlackMessage
        }
        $SlackMessage
    }
}