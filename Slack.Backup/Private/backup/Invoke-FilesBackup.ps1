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

        $files = Get-FilesList -Token $key -TsFrom $start
        if ($files.ok) {
            foreach ($f in $files | Select-Object -ExpandProperty files) {
                $ext = $f.filetype
                $path = "$backupLoc/$($f.id)"
                Get-SlackFile -Token $key -Uri $f.url_private | Set-Content "$path.$ext" -AsByteStream
                $f | ConvertTo-Json -Depth 10 | Set-Content -Path "$path.json"
            }
        }
    }
}