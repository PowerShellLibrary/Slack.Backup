function Convert-EpochToDate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [double]$ctime
    )

    begin {
        Write-Verbose "Cmdlet Convert-EpochToDate - Begin"
    }

    process {
        Write-Verbose "Cmdlet Convert-EpochToDate - Process"
        [datetime]$origin = '1970-01-01 00:00:00'
        $origin.AddSeconds($ctime)
    }

    end {
        Write-Verbose "Cmdlet Convert-EpochToDate - End"
    }
}