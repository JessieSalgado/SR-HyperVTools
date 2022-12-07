function Set-VMGPUAdapter {
    param(
        [string]$VMName,
        [string]$GPUName,
        [decimal]$GPUResourceAllocationPercentage = 100
    )
        
    $PartitionableGPUList = Get-WmiObject -Class "Msvm_PartitionableGpu" -ComputerName $env:COMPUTERNAME -Namespace "ROOT\virtualization\v2" 
    if ($GPUName -eq "AUTO") {
        $DevicePathName = $PartitionableGPUList.Name[0]
        Add-VMGpuPartitionAdapter -VMName $VMName
    }
    else {
        $DeviceID = ((Get-WmiObject Win32_PNPSignedDriver | Where-Object { ($_.Devicename -eq "$GPUNAME") }).hardwareid).split('\')[1]
        $DevicePathName = ($PartitionableGPUList | Where-Object name -like "*$deviceid*").Name
        Add-VMGpuPartitionAdapter -VMName $VMName -InstancePath $DevicePathName
    }
    
    [float]$divider = [math]::round($(100 / $GPUResourceAllocationPercentage), 2)
    
    Set-VMGpuPartitionAdapter -VMName $VMName `
        -MinPartitionVRAM ([math]::round($(1000000000 / $divider))) `
        -MaxPartitionVRAM ([math]::round($(1000000000 / $divider))) `
        -OptimalPartitionVRAM ([math]::round($(1000000000 / $divider))) `
        -MinPartitionEncode ([math]::round($(18446744073709551615 / $divider))) `
        -MaxPartitionEncode ([math]::round($(18446744073709551615 / $divider))) `
        -OptimalPartitionEncode ([math]::round($(18446744073709551615 / $divider))) `
        -MinPartitionDecode ([math]::round($(1000000000 / $divider))) `
        -MaxPartitionDecode ([math]::round($(1000000000 / $divider))) `
        -OptimalPartitionDecode ([math]::round($(1000000000 / $divider))) `
        -MinPartitionCompute ([math]::round($(1000000000 / $divider))) `
        -MaxPartitionCompute ([math]::round($(1000000000 / $divider))) `
        -OptimalPartitionCompute ([math]::round($(1000000000 / $divider)))
    <#Set-VMGPUPartitionAdapter -VMName $VMName `
        -MinPartitionEncode ([math]::round($(18446744073709551615 / $divider))) `
        -MaxPartitionEncode ([math]::round($(18446744073709551615 / $divider))) `
        -OptimalPartitionEncode ([math]::round($(18446744073709551615 / $divider)))
    Set-VMGpuPartitionAdapter -VMName $VMName `
        -MinPartitionDecode ([math]::round($(1000000000 / $divider))) `
        -MaxPartitionDecode ([math]::round($(1000000000 / $divider))) `
        -OptimalPartitionDecode ([math]::round($(1000000000 / $divider)))
    Set-VMGpuPartitionAdapter -VMName $VMName `
        -MinPartitionCompute ([math]::round($(1000000000 / $divider))) `
        -MaxPartitionCompute ([math]::round($(1000000000 / $divider))) `
        -OptimalPartitionCompute ([math]::round($(1000000000 / $divider)))
    #>
    
}