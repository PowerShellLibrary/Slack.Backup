function Invoke-SlackAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Method,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$Token,
        [Parameter(Mandatory = $false, Position = 2 )]
        [System.Collections.Hashtable]$Parameters
    )

    begin {
        Write-Verbose "Cmdlet Invoke-SlackAPI - Begin"
    }

    process {
        Write-Verbose "Cmdlet Invoke-SlackAPI - Process"
        $headers = Get-RequestHeader $Token

        $uri = "https://slack.com/api/$Method"
        if ($Parameters.Keys.Count -gt 0) {
            $qs = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            foreach ($key  in $Parameters.Keys) {
                $value = $Parameters.$key
                if ($value) {
                    $qs.Add($key, $value)
                }
            }
            $uriRequest = [System.UriBuilder]$uri
            $uriRequest.Query = $qs.ToString()
            $uri = $uriRequest.ToString()
        }

        try {
            $response = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers
        }
        catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            if ($_.Exception.Response.StatusCode -eq 429) {
                [int] $delay = [int](($_.Exception.Response.Headers | Where-Object Key -eq 'Retry-After').Value[0])
                Write-Host -Message "Retry caught, delaying $delay s"
                Start-Sleep -Seconds $delay
                return Invoke-SlackAPI -Method $Method -Token $Token -Parameters $Parameters
            }
        }
        $response = $response.Content | ConvertFrom-Json
        if ($response.ok) {
            $response
        }
        else {
            Write-Error "$response.error"
        }
    }

    end {
        Write-Verbose "Cmdlet Invoke-SlackAPI - End"
    }
}