function Assert-Path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Path
    )
    process {
        Write-Verbose "Cmdlet Assert-Path - Process"

        if (!(Test-Path $Path -PathType Container)) {
            New-Item -ItemType Directory -Force -Path $Path | Out-Null
        }
    }
}