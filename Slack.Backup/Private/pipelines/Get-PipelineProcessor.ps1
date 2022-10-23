function Get-PipelineProcessor {
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Name,

        [Parameter(Mandatory = $true, Position = 0 )]
        [System.Object[]]$Parameters
    )
    process {
        Get-Command -Name $Name -CommandType Alias | `
            Sort-Object -Property Name | `
            ? { $_.Parameters.Count -gt 0 } | `
            ? {
            $commandParameters = $_.Parameters
            $valid = $true
            $Parameters | % {
                $valid = $valid -and ($commandParameters.ContainsKey($_.Name) -and $commandParameters[$_.Name].ParameterType.Name -eq $_.Type)
            }
            $valid
        }
    }
}