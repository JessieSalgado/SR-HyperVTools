Function Dismount-ISO {
    param (
    [string]$SourcePath
    )
    $disk = Get-Volume | Where-Object {$_.DriveType -eq "CD-ROM"} | Select-Object *
    Foreach ($d in $disk) {
        Dismount-DiskImage -ImagePath $sourcePath | Out-Null
        }
    }