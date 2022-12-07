Function Mount-ISOReliable {
    param (
        [string]$SourcePath
    )

    Function Get-NewDriveLetter {
        $UsedDriveLetters = ((Get-Volume).DriveLetter) -join ""
        Do {
            $DriveLetter = (65..90) | Get-Random | ForEach-Object { [char]$_ }
        }
        Until (!$UsedDriveLetters.Contains("$DriveLetter"))
        $DriveLetter
    }
    
    $mountResult = Mount-DiskImage -ImagePath $SourcePath
    
    $delay = 0
    Do {
        if ($delay -gt 15) {
            $DriveLetter = "$(Get-NewDriveLetter)" + ":"
            Get-WmiObject -Class Win32_volume | Where-Object { $_.Label -eq "CCCOMA_X64FRE_EN-US_DV9" } | Set-WmiInstance -Arguments @{DriveLetter = "$driveletter" }
        }
        Start-Sleep -s 1 
        $delay++
    }
    Until ($NULL -ne ($mountResult | Get-Volume).DriveLetter)
    ($mountResult | Get-Volume).DriveLetter
}