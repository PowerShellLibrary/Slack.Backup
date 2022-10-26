class Net {
    hidden static [Net] $_instance = [Net]::new()
    static [Net] $Instance = [Net]::GetInstance()


    [Net.WebClient]$WebClient = [Net.WebClient]::new()

    hidden Net() {}

    hidden static [Net] GetInstance() {
        return [Net]::_instance
    }
}
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
        }
        else {
            [Net]::Instance.WebClient.Headers.Clear()
            $headers.Keys | % {
                [Net]::Instance.WebClient.Headers.Add($_, $headers[$_])
            }
            [byte[]]$response = [Net]::Instance.WebClient.DownloadData($Uri)
            Write-Output $response -NoEnumerate
        }
    }

    end {
        Write-Verbose "Cmdlet Get-SlackFile - End"
    }
}