function Invoke-FilesBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$Token,
        [Parameter(Mandatory = $true, Position = 1 )]
        [string]$Location
    )
    process {
        Write-Verbose "Cmdlet Invoke-FilesBackup - Process"

        $backupLoc = "$Location/files"
        Assert-Path $backupLoc

        $start = Get-ChildItem -Path $backupLoc -Filter *.json |`
            % { $_ | Get-Content -Encoding UTF8 | ConvertFrom-Json } |`
            Select-Object -ExpandProperty created |`
            Measure-Object -Maximum |`
            Select-Object -ExpandProperty Maximum |`
            % { $_ + 1 }

        if (!$start) {
            $start = Convert-DateToEpoch (Get-Date "2000-01-01")
        }

        # Collect every page: files.list returns newest first, one page at a time.
        $files = @()
        $page = 1
        do {
            $response = Get-FilesList -Token $Token -TsFrom $start -Page $page
            if (!$response.ok) {
                break
            }
            $files += $response.files
            $pages = if ($response.paging.pages) { [int]$response.paging.pages } else { 1 }
            $page++
        } while ($page -le $pages)

        # Process oldest first. Resuming relies on max(created) of the files already saved,
        # so a run that stops early (time limit, crash) must never leave older files behind.
        $files = @($files | Sort-Object -Property @{ Expression = { [long]$_.created } }, id)

        $cur = 0
        foreach ($f in $files) {
            $ext = $f.filetype
            $path = "$backupLoc/$($f.id)"
            $perc = ((100.0 * $cur++) / $files.Count)
            Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Downloading"
            $slackFile = Get-SlackFile -Token $Token -Uri $f.url_private

            if ($slackFile.Length -eq 0) {
                Write-Host "File $($f.id) is empty or could not be downloaded."
                continue
            }

            Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Running FileDataProcessingPipeline"
            $slackFile = Invoke-FileDataProcessingPipeline -SlackFile $slackFile -Metadata $f
            [System.IO.File]::WriteAllBytes("$path.$ext", $slackFile)
            Remove-Variable -Name slackFile

            Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Running FileProcessingPipeline"
            $f | Invoke-FileProcessingPipeline | ConvertTo-Json -Depth 10 | Set-Content -Path "$path.json"
        }
    }
}
