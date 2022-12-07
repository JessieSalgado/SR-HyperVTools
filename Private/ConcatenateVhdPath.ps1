Function ConcatenateVHDPath {
    param(
        [string]$VHDPath,
        [string]$VMName,
        [string]$VhdFormat,
        [string]$DiskLayout
    )

    if ($VHDFormat -ilike "AUTO")
    {
        if ($DiskLayout -eq "BIOS")
        {
            $VHDFormat = "VHD"
        }
        else
        {
            $VHDFormat = "VHDX"
        }
    }

    if ($VHDPath[-1] -eq '\') {
        $VHDPath + $VMName + "." + $VHDFormat
    }
    Else {
        $VHDPath + "\" + $VMName + "." + $VHDFormat
    }
}