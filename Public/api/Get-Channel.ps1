function Get-Channel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $false, Position = 1 )]
        [int]$Limit = 1000
    )

    begin {
        Write-Verbose "Cmdlet Get-Channel - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-Channel - Process"
        $params = @{
            'limit'   = $Limit
        }
        Invoke-SlackAPI -Method 'conversations.list' -Token $Token -Parameters $params
    }

    end {
        Write-Verbose "Cmdlet Get-Channel - End"
    }
}