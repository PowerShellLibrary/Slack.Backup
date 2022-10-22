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

        $response = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers
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