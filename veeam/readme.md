# ./Get-VeeamBackupStatus.ps1

## SYNOPSIS
Retrieves Veeam job status in PRTG compatible format

## SYNTAX
```powershell
./Get-VeeamBackupStatus.ps1 -JobName <String> -ComputerName <String> [-Credential <PSCredential>] [<CommonParameters>]

./Get-VeeamBackupStatus.ps1 -JobName <String> -ComputerName <String> [-Username <String>] [-Password <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-VeeamBackupStatus.ps1 creates a remote session to a Veeam Backup & Replication server to retrieve job status. Every VM backed up in the job is listed as a channel. The XML output can be used for a PRTG sensor.

## PARAMETERS
### -JobName &lt;String&gt;
Represents the name of the job in Veeam to get the information from.
```
-JobName <String>
    Represents the name of the job in Veeam to get the information from.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ComputerName &lt;String&gt;
Represents the Veeam server to connect to.
```
-ComputerName <String>
    Represents the Veeam server to connect to.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Credentials used to connect to the Veeam server
```
-Credential <PSCredential>
    Credentials used to connect to the Veeam server
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Username &lt;String&gt;
Username to connect to server (for use in prtg)
```
-Username <String>
    Username to connect to server (for use in prtg)
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Password &lt;String&gt;
Password to connect to server (for use in prtg)
```
-Password <String>
    Password to connect to server (for use in prtg)
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## NOTES
```
For the lookup in PRTG to work you need to copy the file "custom.veeam.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.2
Version History:
    1.2  2019.01.24  Add option Warning for single VM
    1.1  2018.07.29  Added PRTG Credential Option
    1.0  2018.06.07  Initial release
```

## INPUTS


## OUTPUTS


## EXAMPLES
### EXAMPLE 1
```powershell
Retrieves Veeam backup status for specified job.
Get-VeeamBackupStatus.ps1 -ComputerName "VeeamServer" -Credential $(New-PSCredential user) -JobName "Accounting VMs"
```
    
 
### EXAMPLE 2
```powershell
Retrieves Veeam backup status for specified job using PRTG credentials
Get-VeeamBackupStatus.ps1 -ComputerName "VeeamServer" -Username '%windowsdomain\%windowsuser' -Password '%windowspassword' -JobName "Accounting VMs"
```
    

