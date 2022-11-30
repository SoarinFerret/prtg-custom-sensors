# ./Get-FazDeviceStatus.ps1

## SYNOPSIS
This is a simple Powershell script to pull Device Status from a FortiAnalyzer

## SYNTAX
```powershell
./Get-FazDeviceStatus.ps1 [-ComputerName <String>] [-Credential <PSCredential>] [-AdomName <String>] [<CommonParameters>]

./Get-FazDeviceStatus.ps1 [-ComputerName <String>] [-Username <String>] [-Password <String>] [-AdomName <String>] [<CommonParameters>]
```

## DESCRIPTION
This script uses the FortiAnalyzer JSON-RPC API to pull the logging status of each device connected to the FortiAnalyzer.

## PARAMETERS
### -ComputerName &lt;String&gt;
Represents the FortiAnalyzer to connect to.
```
-ComputerName <String>
    Represents the FortiAnalyzer to connect to.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Credentials used to connect to the FortiAnalyzer. Make sure the user has JSON API Access enabled
```
-Credential <PSCredential>
    Credentials used to connect to the FortiAnalyzer. Make sure the user has JSON API Access enabled
    
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
 
### -AdomName &lt;String&gt;
Limit the devices returned by Adom
```
-AdomName <String>
    Limit the devices returned by Adom
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## EXAMPLES    
### EXAMPLE 1
```powershell
Returns the devices by a specified ADOM
Get-FazDeviceStatus.ps1 -ComputerName "faz.example.com" -Credential (get-credential root) -AdomName "TEST"
```
    

## NOTES
```
Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2021.02.08  Initial release
```

## INPUTS


## OUTPUTS

