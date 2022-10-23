function Invoke-MessageProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackMessage
    )
    process {
        Get-Command -Name Invoke-MessageProcessor*  -CommandType Alias | `
            Sort-Object -Property Name | `
            ? { $_.Parameters.ContainsKey("SlackMessage") } | `
            ? { $_.Parameters['SlackMessage'].ParameterType.Name -eq "Object" } | `
            % {
                Write-Verbose "Invoking processor: $($_.Name)"
                $SlackMessage = &($_.Name) -SlackMessage $SlackMessage
            }
        $SlackMessage
    }
}