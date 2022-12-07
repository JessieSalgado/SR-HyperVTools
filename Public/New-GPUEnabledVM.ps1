function New-GPUEnabledVM {
    [CmdletBinding(DefaultParameterSetName = "Standard")]
    param (
        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(512MB, 64TB)]
        [int64]$SizeBytes = 60GB,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [int]$Edition,

        [Parameter(Mandatory = $true,ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true,ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("VHD", "VHDX", "AUTO")]
        [string]$VhdFormat,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                $Entry = $_
                if (!(Test-Path $Entry)) {
                    $dirCreate = Read-Host "The Directory $Entry doesn't exist.`nWould you like to create it? (y/n)"
                    if ($dirCreate -eq 'y' -or $dirCreate -eq 'yes') {
                        New-Item -Path $Entry -ItemType Directory
                    }
                }
                Test-Path -Path (Resolve-Path -Path $Entry)
            }
        )]
        [string]$VhdPath,

        [Parameter(Mandatory = $true,
            ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true,
            ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [string]$VMName,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("BIOS", "UEFI", "WindowsToGo")]
        [string]$DiskLayout = "UEFI",

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$UnattendPath = "$PSScriptRoot\..\Private\autounattend.xml",

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(512MB, 1TB)]
        [int64]$MemoryAmount = 8GB,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [int]$CPUCores = 4,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [string]$NetworkSwitch,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [string]$GPUName,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 100)]
        [float]$GPUResourceAllocationPercentage,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$SourcePath,

        [Parameter(ParameterSetName = "Parsec")]
        [string]$Team_ID,

        [Parameter(ParameterSetName = "Parsec")]
        [string]$Key,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [SecureString]$Password,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [switch]$autologon,

        [Parameter(ParameterSetName = "Parsec")]
        [Alias("Parsec")]
        [bool]$ParsecInstall,

        [Parameter(ParameterSetName = "Standard")]
        [Parameter(ParameterSetName = "Parsec")]
        [ValidateNotNullOrEmpty()]
        [string]$ProductKey
    )
    
    begin {
        Function Test-Administrator {  
            $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
            (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        }
        function Test-SourceIso {
            param (
                $SourcePath
            )

            if (!(Test-Path $SourcePath) -or ($SourcePath -notlike "*.iso")) {
                return $false
            }

            $ISODriveLetter = Mount-ISOReliable -SourcePath $SourcePath
            $ISOTest = Test-Path $("$ISODriveLetter" + ":\Sources\install.wim")

            if ($ISOTest) { Dismount-ISO -SourcePath $SourcePath }
            return $ISOTest
        }
        Function Test-Names {
            param (
                [string]
                $Username,
                [string]
                $VMName
            )

            while ($UserName -notmatch "^[a-zA-Z0-9_-]+$") {
                $Username = Read-Host -Prompt "Enter a valid username"
            }

            while ($UserName -eq $VMName -or $VMName.Length -ge 15) {
                $VMName = Read-Host -Prompt "Enter a valid hostname for the virual machine"
            }

            @{
                VMName   = $VMName
                Username = $Username
            }
        }
    }
    
    process {
        if (!(Test-Administrator)) {
            $ErrorRecordType = [System.Management.Automation.ErrorRecord]
            $ErrorRecord = $ErrorRecordType::new([System.Security.AccessControl.PrivilegeNotHeldException]::new("Administrators"), 'ErrorId', 'PermissionDenied', $null)
            $ErrorRecordType.InvokeMember('SetInvocationInfo', 'Instance, NonPublic, InvokeMethod', $null, $ErrorRecord, $MyInvocation)
            throw $ErrorRecord
        }

        $Names = Test-Names -Username $Username -VMName $VMName
        $Username = $Names.Username
        $VMName = $Names.VMName

        if (!$password) {
            $password = Read-Host -Prompt "Enter a password for $Username" -AsSecureString
        }

        if (!$GPUName) {
            Get-VMGpuPartitionAdapterFriendlyName
            $GPUName = Read-Host -Prompt "Enter Auto or the GPU name to use"

            
            if (([Environment]::OSVersion.Version.Build -lt 22000) -and ($GPUName -ne "AUTO")) {
                Write-Warning -Message "Must use AUTO on systems with builds 22000 and under."
                $GPUName = "AUTO"
            }
        }

        $SourceTest = Test-SourceIso -SourcePath $SourcePath
        if (!($SourceTest)) {
            $ErrorRecordType = [System.Management.Automation.ErrorRecord]
            $ErrorRecord = $ErrorRecordType::new([System.IO.FileNotFoundException]::new("The source $($SourcePath) is not a valid ISO File"), 'ErrorId', 'ObjectNotFound', $null)
            $ErrorRecordType.InvokeMember('SetInvocationInfo', 'Instance, NonPublic, InvokeMethod', $null, $ErrorRecord, $MyInvocation)
            throw $ErrorRecord
        }

        $DriveLetter = Mount-ISOReliable -SourcePath $SourcePath
        
        while ($null -ne (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
            $VMName = Read-Host -Prompt "Virtual Machine $VMName already exists, please enter a new name"            
        }

        do {
            [string]$ConcatVHDPath = ConcatenateVHDPath -VHDPath $VHDPath -VMName $VMName -VHDFormat $VhdFormat -DiskLayout $DiskLayout
            if (Test-Path -Path $ConcatVHDPath){$VMName = Read-Host -Prompt "Virtual Machine Disk already exists at $ConcatVhdPath. Enter a new VMName"}

        } while (
            Test-Path $ConcatVHDPath
        )

        if (!$Edition) {
            Get-WindowsImage -ImagePath "$($DriveLetter):\sources\install.wim" | Format-Table -AutoSize -Property ImageIndex, ImageName -HideTableHeaders
            [Int32]$Edition = Read-Host -Prompt "Enter the value for the edition you wish to install"
        }

        if (!$ProductKey) {
            $ProductKey = Read-Host -Prompt "Enter a Windows Product Key (optional)"
        }

        if (!$NetworkSwitch) {
            Get-VMSwitch | Format-Table -AutoSize -Property Name -HideTableHeaders
            [string]$NetworkSwitch = Read-Host -Prompt "Enter the switch name to connect to."
        }

        Set-AutoUnattend -username $username -password $password -autologon $autologon -hostname $VMName -UnattendPath $UnattendPath -ProductKey $ProductKey
        $MaxAvailableVersion = (Get-VMHostSupportedVersion).Version | Where-Object { $_.Major -lt 254 } | Select-Object -Last 1 
        Convert-WindowsImage -SourcePath $SourcePath `
            -ISODriveLetter $DriveLetter `
            -Edition $Edition `
            -VHDFormat $Vhdformat `
            -VHDPath $ConcatVhdPath `
            -DiskLayout $DiskLayout `
            -UnattendPath $UnattendPath `
            -GPUName $GPUName `
            -ParsecInstall $ParsecInstall `
            -Team_ID $(if ($Team_ID) { $Team_ID }else { "" }) `
            -Key $(if ($Key) { $Key }else { "" }) `
            -SizeBytes $SizeBytes | Out-Null

        if (Test-Path $ConcatvhdPath) {
            New-VM -Name $VMName `
                -MemoryStartupBytes $MemoryAmount `
                -VHDPath $ConcatVhdPath `
                -Generation 2 `
                -SwitchName $NetworkSwitch `
                -Version $MaxAvailableVersion | Out-Null
            Set-VM -Name $VMName `
                -ProcessorCount $CPUCores `
                -CheckpointType Disabled `
                -LowMemoryMappedIoSpace 3GB `
                -HighMemoryMappedIoSpace 32GB `
                -GuestControlledCacheTypes $true `
                -AutomaticStopAction ShutDown
            Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false 
            $CPUManufacturer = Get-CimInstance -ClassName Win32_Processor | Foreach-Object Manufacturer
            $BuildVer = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            if (($BuildVer.CurrentBuild -lt 22000) -and ($CPUManufacturer -eq "AuthenticAMD")) {
            }
            Else {
                Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
            }
            Set-VMHost -ComputerName $ENV:Computername -EnableEnhancedSessionMode $false
            Set-VMVideo -VMName $VMName -HorizontalResolution 1920 -VerticalResolution 1080
            Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector
            Enable-VMTPM -VMName $VMName 
            Add-VMDvdDrive -VMName $VMName -Path $SourcePath
            Set-VMGPUAdapter -GPUName $GPUName -VMName $VMName -GPUResourceAllocationPercentage $GPUResourceAllocationPercentage
            Write-Host "INFO   : Starting and connecting to VM"
            vmconnect localhost $VMName
        }
        else {
            $ErrorRecordType = [System.Management.Automation.ErrorRecord]
            $ErrorRecord = $ErrorRecordType::new([System.InvalidOperationException]::new("Failed to provision the $VhdFormat"), 'ErrorId', 'InvalidArgument', $null)
            $ErrorRecordType.InvokeMember('SetInvocationInfo', 'Instance, NonPublic, InvokeMethod', $null, $ErrorRecord, $MyInvocation)
            throw $ErrorRecord
        }
    }
    
    end {
        Start-VM -Name $VMName
        Write-Host -Object "Starting the Virtual Machine $VMName.`nIf Parsec was installed, sign into Parsec and connect from a remote computer."
    }
}