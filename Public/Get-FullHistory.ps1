function Get-FullHistory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$ChannelId,
        [Parameter(Mandatory = $true, Position = 2 )]
        [string]$Start
    )

    begin {
        Write-Verbose "Cmdlet Get-FullHistory - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-FullHistory - Process"
        $channelMessages = @()
        do {
            $response = Get-History -Token $Token -ChannelId $ChannelId -Oldest $Start -Limit 1000
            if ($response.ok -eq $false) {
                Write-Error $response.error
            }
            $sorted = $response.messages | Sort-Object { Convert-EpochToDate ($_.ts) }
            $last = $sorted  | Select-Object -Last 1
            $Start = $last.ts
            $channelMessages += $sorted
        } while ($response.has_more -and $response)
        $channelMessages | ? { $_.thread_ts -ne $null } | % {
            $response = Get-Thread -Token $Token -ChannelId $ChannelId -ThreadTs $_.ts
            if ($response.ok -eq $false) {
                Write-Error $response.error
            }
            $channelMessages += $response.messages | Select-Object -Skip 1
        }
        $channelMessages | Sort-Object { Convert-EpochToDate ($_.ts) }
    }

    end {
        Write-Verbose "Cmdlet Get-FullHistory - End"
    }
}