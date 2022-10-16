function Convert-DateToEpoch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [datetime]$end
    )

    begin {
        Write-Verbose "Cmdlet Convert-DateToEpoch - Begin"
    }

    process {
        Write-Verbose "Cmdlet Convert-DateToEpoch - Process"
        [datetime]$origin = '1970-01-01 00:00:00'
        (New-TimeSpan -Start $origin -End $end).TotalSeconds
    }

    end {
        Write-Verbose "Cmdlet Convert-DateToEpoch - End"
    }
}