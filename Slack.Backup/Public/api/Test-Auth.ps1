function Test-Auth {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token
    )

    begin {
        Write-Verbose "Cmdlet Test-Auth - Begin"
    }

    process {
        Write-Verbose "Cmdlet Test-Auth - Process"

        $response = Invoke-SlackAPI -Method 'auth.test' -Token $Token
        if ($response.ok -eq $false) {
            Write-Error $response.error
            $false
        }
        else {
            $true
        }
    }

    end {
        Write-Verbose "Cmdlet Test-Auth - End"
    }
}