Function Install-Parsec {
    param(
        [string]$DriveLetter,
        [string]$Team_ID,
        [string]$Key
    )
    $new = @()
    
    $content = get-content "$PSScriptRoot\Private\user\psscripts.ini" 
    
    foreach ($line in $content) {
        if ($line -like "0Parameters=") {
            $line = "0Parameters=-team_id=$Team_ID -team_key=$Key"
            $new += $line
        }
        Else {
            $new += $line
        }
    }
    Set-Content -Value $new -Path "$PSScriptRoot\Private\user\psscripts.ini"
    if ((Test-Path -Path $DriveLetter\Windows\system32\GroupPolicy\User\Scripts\Logon) -eq $true) {} Else { New-Item -Path $DriveLetter\Windows\system32\GroupPolicy\User\Scripts\Logon -ItemType directory | Out-Null }
    if ((Test-Path -Path $DriveLetter\Windows\system32\GroupPolicy\User\Scripts\Logoff) -eq $true) {} Else { New-Item -Path $DriveLetter\Windows\system32\GroupPolicy\User\Scripts\Logoff -ItemType directory | Out-Null }
    if ((Test-Path -Path $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts\Startup) -eq $true) {} Else { New-Item -Path $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory | Out-Null }
    if ((Test-Path -Path $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown) -eq $true) {} Else { New-Item -Path $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory | Out-Null }
    if ((Test-Path -Path $DriveLetter\ProgramData\Easy-GPU-P) -eq $true) {} Else { New-Item -Path $DriveLetter\ProgramData\Easy-GPU-P -ItemType directory | Out-Null }
    Copy-Item -Path $psscriptroot\Private\VMScripts\VDDMonitor.ps1 -Destination $DriveLetter\ProgramData\Easy-GPU-P
    Copy-Item -Path $psscriptroot\Private\VMScripts\VBCableInstall.ps1 -Destination $DriveLetter\ProgramData\Easy-GPU-P
    Copy-Item -Path $psscriptroot\Private\VMScripts\ParsecVDDInstall.ps1 -Destination $DriveLetter\ProgramData\Easy-GPU-P
    Copy-Item -Path $psscriptroot\Private\VMScripts\ParsecPublic.cer -Destination $DriveLetter\ProgramData\Easy-GPU-P
    Copy-Item -Path $psscriptroot\Private\VMScripts\Parsec.lnk -Destination $DriveLetter\ProgramData\Easy-GPU-P
    Copy-Item -Path $psscriptroot\Private\gpt.ini -Destination $DriveLetter\Windows\system32\GroupPolicy
    Copy-Item -Path $psscriptroot\Private\User\psscripts.ini -Destination $DriveLetter\Windows\system32\GroupPolicy\User\Scripts
    Copy-Item -Path $psscriptroot\Private\User\Install.ps1 -Destination $DriveLetter\Windows\system32\GroupPolicy\User\Scripts\Logon
    Copy-Item -Path $psscriptroot\Private\Machine\psscripts.ini -Destination $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts
    Copy-Item -Path $psscriptroot\Private\Machine\Install.ps1 -Destination $DriveLetter\Windows\system32\GroupPolicy\Machine\Scripts\Startup
}