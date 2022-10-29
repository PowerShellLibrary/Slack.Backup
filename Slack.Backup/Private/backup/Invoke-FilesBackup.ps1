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

        $files = Get-FilesList -Token $Token -TsFrom $start
        if ($files.ok) {
            $cur = 0
            $files = $files | Select-Object -ExpandProperty files
            foreach ($f in $files) {
                $ext = $f.filetype
                $path = "$backupLoc/$($f.id)"
                $perc = ((100.0 * $cur++) / $files.Count)
                Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Downloading"
                $slackFile = Get-SlackFile -Token $Token -Uri $f.url_private

                Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Running FileDataProcessingPipeline"
                $slackFile = Invoke-FileDataProcessingPipeline -SlackFile $slackFile -Metadata $f
                [System.IO.File]::WriteAllBytes("$path.$ext", $slackFile)
                Remove-Variable -Name slackFile

                Write-Progress -Activity "File $($f.id)" -PercentComplete $perc -Status "Running FileProcessingPipeline"
                $f | Invoke-FileProcessingPipeline | ConvertTo-Json -Depth 10 | Set-Content -Path "$path.json"
            }
        }
    }
}