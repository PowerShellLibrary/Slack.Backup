function Get-Thread {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$ChannelId,
        [Parameter(Mandatory = $true, Position = 2 )]
        [string]$ThreadTs,
        [Parameter(Mandatory = $false, Position = 3 )]
        [int]$Limit = 1000
    )

    begin {
        Write-Verbose "Cmdlet Get-Thread - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-Thread - Process"
        $params = @{
            'channel' = $ChannelId;
            'ts'      = $ThreadTs;
            'limit'   = $Limit
        }
        Invoke-SlackAPI -Method 'conversations.replies' -Token $Token -Parameters $params
    }

    end {
        Write-Verbose "Cmdlet Get-Thread - End"
    }
}