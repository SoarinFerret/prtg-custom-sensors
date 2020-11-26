# ./Get-ZFSPoolHealth.ps1

## SYNOPSIS
Retrives health data for a specifed zpool on a server running ZFS

## SYNTAX
```powershell
./Get-ZFSPoolHealth.ps1 -ComputerName <String> [-Credential <PSCredential>] [-Port <Int32>] -Pool <String> [-OverrideOldKey] [<CommonParameters>]

./Get-ZFSPoolHealth.ps1 -ComputerName <String> [-Username <String>] [-Password <String>] [-Port <Int32>] -Pool <String> [-OverrideOldKey] [<CommonParameters>]
```

## DESCRIPTION
Retrieves health data for appropriate mirrors, disks, and overall pool health via SSH, and returns it in JSON format suitable for PRTG

## PARAMETERS
### -ComputerName &lt;String&gt;
Represents the server to connect to.
```
-ComputerName <String>
    Represents the server to connect to.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Credentials used to connect to the server
```
-Credential <PSCredential>
    Credentials used to connect to the server
    
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
 
### -Port &lt;Int32&gt;
SSH port on server
```
-Port <Int32>
    SSH port on server
    
    Required?                    false
    Position?                    named
    Default value                22
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Pool &lt;String&gt;
Name of the zpool
```
-Pool <String>
    Name of the zpool
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -OverrideOldKey &lt;SwitchParameter&gt;

```
-OverrideOldKey [<SwitchParameter>]
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## EXAMPLES    
### EXAMPLE 1
```powershell
Retrieves disk health for specified pool.
Get-ZFSPoolHealth.ps1 -ComputerName "zol" -Credential $(Get-Credential root) -Pool "tank"
```

### EXAMPLE 2
```powershell
Retrieves disk health for specified pool using PRTG credentials
Get-ZFSPoolHealth.ps1 -ComputerName "zol" -Username '%linuxuser' -Password '%linuxpassword' -Pool "tank"
```
    

## NOTES
```
Requires Posh-SSH module to loaded in PowerShell

For the lookup in PRTG to work you need to copy the file "custom.zfspoolhealth.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.1
Version History:
    1.0  2018.10.28  Initial release
    1.1  2020.11.25  Updated for Generic ZFS server
                     Added option to override SSH key changes
    1.2  2020.11.26  Fixed Disk Output for ZoL
```

## INPUTS


## OUTPUTS

