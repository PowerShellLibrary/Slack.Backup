function Get-History {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$ChannelId,
        [Parameter(Mandatory = $true, Position = 2 )]
        [string]$Oldest,
        [Parameter(Mandatory = $false, Position = 3 )]
        [int]$Limit = 100
    )

    begin {
        Write-Verbose "Cmdlet Get-History - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-History - Process"
        $params = @{
            'channel' = $ChannelId;
            'oldest'  = $Oldest;
            'limit'   = $Limit
        }
        Invoke-SlackAPI -Method 'conversations.history' -Token $Token -Parameters $params
    }

    end {
        Write-Verbose "Cmdlet Get-History - End"
    }
}