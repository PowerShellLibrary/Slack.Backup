function Invoke-FileDataProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [byte[]]$SlackFile
    )
    process {
        Get-Command -Name Invoke-FileDataProcessor* -CommandType Alias | `
            Sort-Object -Property Name | `
            ? { $_.Parameters.Count -gt 0 } | `
            ? { $_.Parameters.ContainsKey("SlackFile") } | `
            ? { $_.Parameters['SlackFile'].ParameterType.Name -eq [byte[]] } | `
            % {
                Write-Verbose "Invoking processor: $($_.Name)"
                $SlackFile = &($_.Name) -SlackFile $SlackFile
            }
        $SlackFile
    }
}