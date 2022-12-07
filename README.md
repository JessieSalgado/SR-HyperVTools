# SR-HyperVTools
This module started off as an effort to convert [Easy-GPU-PV](https://github.com/jamesstringerparsec/Easy-GPU-PV) into a PowerShell module. Many changes were made to make this happen.

I hope this will make the creation of a GPU-P enabled VM much easier to create and modify.

## Instructions
* Download the [repo](https://github.com/JessieSalgado/SR-HyperVTools/archive/refs/heads/main.zip) 
* Unblock the zip file by right-clicking and select properties
    * Check the box labeled Unblock and click OK.
* Extract the zip file to the modules folder location.
    * %USERPROFILE%\Documents\PowerShell\Modules
    * %USERPROFILE%\Documents\WindowsPowerShell\Modules
* If the root folder has the branch name on it remove it.
    * SR-HyperVTools-main --> SR-HyperVTools
* Launch a PowerShell window
    * You may need to launch it as an administrator
* For a list of commands currently available in this module run the following:
    * Get-Command -Module SR-HyperVTools -ListAvailable.

## Notes
Some of the change are as follows:
* Parameters are now specified as you would any other CMDLET
    * Ex: New-GPUEnabledVM -User 'Username'
* Some Parameters have a default value set if you don't specify it. Others will prompt you for the information
* There is a paramater that determines if Parsec should install or not.
* Some of the scripts from [Easy-GPU-PV](https://github.com/jamesstringerparsec/Easy-GPU-PV) have not been converted over to the module yet.
    * Ex: Update-VMGpuPartitionDriver.ps1
* This module will work with a Windows Server OS ISO.
    * Tested on Server 2022 Standard running Hyper-V