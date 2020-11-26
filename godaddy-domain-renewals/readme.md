# ./Get-GoDaddyDomains.ps1

## SYNOPSIS
Retrieves the expiration for each GoDaddy domain under your account

## SYNTAX
```powershell
./Get-GoDaddyDomains.ps1 [-DomainFilter <String>] [-Credential <PSCredential>] [-IgnoreStatus] [-ReturnAsObject] [<CommonParameters>]

./Get-GoDaddyDomains.ps1 [-DomainFilter <String>] [-ApiKey <String>] [-ApiSecret <String>] [-IgnoreStatus] [-ReturnAsObject] [<CommonParameters>]
```

## DESCRIPTION
Uses the GoDaddy API to retrieve information about your domains' expiration returned in a PRTG compatible format.

## PARAMETERS
### -DomainFilter &lt;String&gt;
Optionally filter the output of the domains
```
-DomainFilter <String>
    Optionally filter the output of the domains
    
    Required?                    false
    Position?                    named
    Default value                *
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Credential &lt;PSCredential&gt;
Provide the production API Key & Secret as a PSCredential Object
```
-Credential <PSCredential>
    Provide the production API Key & Secret as a PSCredential Object
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ApiKey &lt;String&gt;
Production API Key from GoDaddy
```
-ApiKey <String>
    Production API Key from GoDaddy
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ApiSecret &lt;String&gt;
Production API Secret from GoDaddy
```
-ApiSecret <String>
    Production API Secret from GoDaddy
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -IgnoreStatus &lt;SwitchParameter&gt;
By default, this script only returns domains with an "ACTIVE" or "EXPRIED" status. This flag will return all domains
```
-IgnoreStatus [<SwitchParameter>]
    By default, this script only returns domains with an "ACTIVE" or "EXPRIED" status. This flag will return all domains
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ReturnAsObject &lt;SwitchParameter&gt;
Returns the output as a PSObject with more information. Typically used for debugging.
```
-ReturnAsObject [<SwitchParameter>]
    Returns the output as a PSObject with more information. Typically used for debugging.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## EXAMPLES    
### EXAMPLE 1
```powershell
Get-GoDaddyDomains.ps1 -Credential (get-credential) -ReturnAsObject
```
Retrieves verbose details about all GoDaddy domains as PSObject    

### EXAMPLE 2
```powershell
Get-DockerHubStats.ps1 -ApiKey "xxxxx" -ApiSecret "xxxxx"
```
Returns PRTG compatible output    

## NOTES
```
Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2020.11.26  Initial Release
```

## INPUTS


## OUTPUTS

