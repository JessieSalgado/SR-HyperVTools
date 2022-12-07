Function Set-AutoUnattend {
    param (
        [string]$username,
        [SecureString]$password,
        [string]$autologon,
        [string]$hostname,
        [string]$UnattendPath,
        [string]$ProductKey
    )
    [xml]$xml = get-content -path $UnattendPath
        ($xml.unattend.settings.component | where-object { $_.autologon }).autologon.password.value = $($password | ConvertFrom-SecureString -AsPlainText)
        ($xml.unattend.settings.component | where-object { $_.autologon }).autologon.username = $username
        ($xml.unattend.settings.component | where-object { $_.autologon }).autologon.enabled = $autologon
        ($xml.unattend.settings.component | where-object { $_.UserAccounts }).UserAccounts.LocalAccounts.localaccount.Group = "Administrators"
        ($xml.unattend.settings.component | where-object { $_.UserAccounts }).UserAccounts.LocalAccounts.localaccount.Name = $username
        ($xml.unattend.settings.component | where-object { $_.UserAccounts }).UserAccounts.LocalAccounts.localaccount.DisplayName = $username
        ($xml.unattend.settings.component | where-object { $_.UserAccounts }).UserAccounts.LocalAccounts.localaccount.Password.Value = $($password | ConvertFrom-SecureString -AsPlainText)
        ($xml.unattend.settings.component | where-object { $_.Computername }).Computername = $hostname
        ($xml.unattend.settings.component | where-object { $_.ProductKey }).ProductKey = $ProductKey
        ($xml.unattend.settings.component | where-object { $_.TimeZone }).TimeZone = (Get-TimeZone).Id
    $xml.Save("$UnattendPath")
}