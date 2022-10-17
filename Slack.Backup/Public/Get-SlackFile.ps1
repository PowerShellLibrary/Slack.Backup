function Get-SlackFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$Uri,
        [Parameter(Mandatory = $false, Position = 2 )]
        [string]$OutFile
    )

    begin {
        Write-Verbose "Cmdlet Get-SlackFile - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-SlackFile - Process"
        $headers = Get-RequestHeader $Token
        if ($OutFile) {
            Invoke-WebRequest -Method Get -Uri $Uri -Headers $headers -OutFile $OutFile
        }else{
            Invoke-WebRequest -Method Get -Uri $Uri -Headers $headers | Select-Object -ExpandProperty Content
        }
    }

    end {
        Write-Verbose "Cmdlet Get-SlackFile - End"
    }
}