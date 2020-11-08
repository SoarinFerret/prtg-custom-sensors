# ./Get-FreeNASDiskTemp.ps1

## SYNOPSIS
Retrives smartctl temperature data for all drives on a FreeNAS server

## SYNTAX
```powershell
./Get-FreeNASDiskTemp.ps1 -ComputerName <String> [-Credential <PSCredential>] [-Port <Int32>] [<CommonParameters>]

./Get-FreeNASDiskTemp.ps1 -ComputerName <String> [-Username <String>] [-Password <String>] [-Port <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Retrives smartctl temperature data for all compatible drives on a FreeNAS server via SSH, and then returns it in JSON format suitable for PRTG

## PARAMETERS
### -ComputerName &lt;String&gt;
Represents the FreeNAS server to connect to.
```
-ComputerName <String>
    Represents the FreeNAS server to connect to.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Credentials used to connect to the FreeNAS server
```
-Credential <PSCredential>
    Credentials used to connect to the FreeNAS server
    
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

## EXAMPLES    
### EXAMPLE 1
```powershell
Retrieves disk health for specified pool.
Get-FreeNASDiskHealth.ps1 -ComputerName "freenas" -Credential $(Get-Credential root)
```

### EXAMPLE 2
```powershell
Retrieves disk health for specified pool using PRTG credentials
Get-FreeNASDiskTemps.ps1 -ComputerName "freenas" -Username '%linuxuser' -Password '%linuxpassword'
```    

## NOTES
```
Requires Posh-SSH module to loaded in PowerShell

Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2020.11.07  Initial release
```

## INPUTS


## OUTPUTS

