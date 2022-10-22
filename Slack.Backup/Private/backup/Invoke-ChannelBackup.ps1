function Invoke-ChannelBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$ChannelID,
        [Parameter(Mandatory = $true, Position = 2 )]
        [string]$Location
    )
    process {
        Write-Verbose "Cmdlet Invoke-ChannelBackup - Process"

        $messages = @()
        $start = Convert-DateToEpoch (Get-Date "2000-01-01")

        if (Test-Path $Location) {
            $messages = Get-Content -Path $Location -encoding UTF8 | ConvertFrom-Json
            $last = $messages | Select-Object -Last 1
            $start = $last.ts
        }
        Write-Verbose "Get-ChannelNewMessages [$ChannelId][$(Convert-EpochToDate $Start)]"
        [array]$newMessages = Get-FullHistory -Token $key -ChannelId $ChannelId -Start $start

        $ids = $messages.client_msg_id
        $threadDeep = Convert-DateToEpoch (Get-Date).AddDays(-90)
        $threaded = $messages | ? { $_.reply_count -ne $null } | ? { [double]$_.ts -le $start -and [double]$_.ts -gt $threadDeep }
        $threaded | % {
            $om = $_
            $response = Get-Thread -Token $key -ChannelId $ChannelId -ThreadTs $om.thread_ts
            if ($response.ok -eq $true) {
                $replies = $response.messages
                $nm = $replies | Select-Object -First 1
                if ($nm -and ([double]$nm.latest_reply) -gt ([double]$om.latest_reply)) {
                    Write-Verbose "Update parent message: $($om.client_msg_id)"
                    $index = $messages.IndexOf($om)
                    $messages.Item($index) = $nm

                    $replies | Select-Object -Skip 1 | % {
                        $m = $_
                        if ($ids.Contains($m.client_msg_id) -eq $false) {
                            Write-Verbose "Adding new thread meassage: $($m.client_msg_id)"
                            $newMessages += $m
                        }
                    }
                }
            }
        }

        if ($newMessages.Count -gt 0) {
            $messages += $newMessages
            $messages | Sort-Object -Property @{Expression = { [double]$_.ts } } | ConvertTo-Json -Depth 100 | Set-Content -Path $Location
        }
    }
}