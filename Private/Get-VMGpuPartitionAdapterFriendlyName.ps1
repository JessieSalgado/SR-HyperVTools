Function Get-VMGpuPartitionAdapterFriendlyName {
    $Devices = (Get-WmiObject -Class "Msvm_PartitionableGpu" -ComputerName $env:COMPUTERNAME -Namespace "ROOT\virtualization\v2").name
    Foreach ($GPU in $Devices) {
        $GPUParse = $GPU.Split('#')[1]
        Get-WmiObject Win32_PNPSignedDriver | Where-Object { ($_.HardwareID -eq "PCI\$GPUParse") } | Select-Object DeviceName -ExpandProperty DeviceName
    }
}