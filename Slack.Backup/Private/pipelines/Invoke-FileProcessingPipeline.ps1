function Invoke-FileProcessingPipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [System.Object]$SlackFile
    )
    process {
        Get-Command -Name Invoke-FileProcessor* -CommandType Alias | `
            Sort-Object -Property Name | `
            ? { $_.Parameters.Count -gt 0 } | `
            ? { $_.Parameters.ContainsKey("SlackFile") } | `
            ? { $_.Parameters['SlackFile'].ParameterType.Name -eq "Object" } | `
            % {
                Write-Verbose "Invoking processor: $($_.Name)"
                $SlackFile = &($_.Name) -SlackFile $SlackFile
            }
        $SlackFile
    }
}