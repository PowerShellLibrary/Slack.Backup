function Invoke-BackupJob {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $false, Position = 1 )]
        [string]$Location = ".\backup",
        [Parameter(Mandatory = $false, Position = 2 )]
        [switch]$Channels,
        [Parameter(Mandatory = $false, Position = 3 )]
        [switch]$Files
    )

    begin {
        Write-Verbose "Cmdlet Invoke-BackupJob - Begin"
    }

    process {
        Write-Verbose "Cmdlet Invoke-BackupJob - Process"
        Assert-Path $Location
        $Location = Resolve-Path -LiteralPath $Location | Select-Object -ExpandProperty Path
        if ($Files) {
            Invoke-FilesBackup -Token $Token -Location $Location
        }
        if ($Channels) {
            Invoke-ChannelsBackup -Token $Token -Location $Location
        }
    }

    end {
        Write-Verbose "Cmdlet Invoke-BackupJob - End"
    }
}