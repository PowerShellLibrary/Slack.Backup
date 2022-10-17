function Get-FilesList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $false, Position = 1 )]
        [string]$ChannelId,
        [Parameter(Mandatory = $false, Position = 2 )]
        [string]$TsFrom,
        [Parameter(Mandatory = $false, Position = 3 )]
        [string]$TsTo,
        [Parameter(Mandatory = $false, Position = 4 )]
        [int]$Count = 1000,
        [Parameter(Mandatory = $false, Position = 5 )]
        [int]$Page = 1
    )

    begin {
        Write-Verbose "Cmdlet Get-FilesList - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-FilesList - Process"
        $params = @{
            'channel' = $ChannelId;
            'count'   = $Count;
            'ts_from' = $TsFrom
            'ts_to'   = $TsTo
            'page'    = $Page
        }
        Invoke-SlackAPI -Method 'files.list' -Token $Token -Parameters $params
    }

    end {
        Write-Verbose "Cmdlet Get-FilesList - End"
    }
}