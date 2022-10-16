function Get-RequestHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token
    )

    begin {
        Write-Verbose "Cmdlet Get-RequestHeader - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-RequestHeader - Process"

        $headers = @{'Authorization' = "Bearer $Token"; }
        $headers
    }

    end {
        Write-Verbose "Cmdlet Get-RequestHeader - End"
    }
}