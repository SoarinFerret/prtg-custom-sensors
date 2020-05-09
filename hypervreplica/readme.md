# ./Get-VMReplHealth.ps1

## SYNOPSIS
Retrieves VM replication health in PRTG compatible format

## SYNTAX
```powershell
./Get-VMReplHealth.ps1 -VMName <String> -ComputerName <String> [-Credential <PSCredential>] [<CommonParameters>]

./Get-VMReplHealth.ps1 -VMName <String> -ComputerName <String> [-Username <String>] [-Password <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-VMReplHealth.ps1 creates a remote session to a Hyper-V Replication server to retrieve VM replication health status. The XML output can be used for a PRTG sensor.

## PARAMETERS
### -VMName &lt;String&gt;
Represents the name of the VM to get the health data for.
```
-VMName <String>
    Represents the name of the VM to get the health data for.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ComputerName &lt;String&gt;
Represents the Hyper-V server to connect to.
```
-ComputerName <String>
    Represents the Hyper-V server to connect to.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Credentials used to connect to the Hyper-V server
```
-Credential <PSCredential>
    Credentials used to connect to the Hyper-V server
    
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
For the lookup in PRTG to work you need to copy the file "custom.vmreplhealth.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2018.07.29  Initial release
```

## INPUTS


## OUTPUTS


## EXAMPLES
### EXAMPLE 1
```powershell
Retrieves VM Replication status for specified VM.
Get-VMReplHealth.ps1 -ComputerName "HyperVServer" -Credential $(New-PSCredential user) -VMName "AD"
```
    
 
### EXAMPLE 2
```powershell
Retrieves Veeam backup status for specified job using PRTG credentials
Get-VMReplHealth.ps1 -ComputerName "HyperVServer" -Username '%windowsdomain\%windowsuser' -Password '%windowspassword' -VMName "AD"
```
    

