function Invoke-ChannelsBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$Location
    )
    process {
        Write-Verbose "Cmdlet Invoke-ChannelsBackup - Process"

        $backupLoc = "$Location\channels"
        Assert-Path $backupLoc

        $channels = Get-Channel $Token | Select-Object -ExpandProperty channels
        $channels | ConvertTo-Json -Depth 100 | Set-Content -Path "$backupLoc\channels.json"

        $channels  | % {
            $channelBackupPath = "$backupRoot\channels\$($_.id).json"
            Invoke-ChannelBackup -Token $Token -ChannelId $_.id -Location $channelBackupPath
        }
    }
}