# ./Get-DockerHubRateLimitStatus.ps1

## SYNOPSIS
Retrieves current Docker Hub rate limit in a PRTG Compatible format

## SYNTAX
```powershell
./Get-DockerHubRateLimitStatus.ps1 [-ReturnAsObject] [<CommonParameters>]

./Get-DockerHubRateLimitStatus.ps1 [-Credential <PSCredential>] [-ReturnAsObject] [<CommonParameters>]

./Get-DockerHubRateLimitStatus.ps1 [-Username <String>] [-Password <String>] [-ReturnAsObject] [<CommonParameters>]
```

## DESCRIPTION
Uses the docker hub API to generate PRTG compatible statistics about the current rate limit status. Optionally can use Docker Hub credentials.

## PARAMETERS
### -Credential &lt;PSCredential&gt;
Represents the Docker Hub credentials to authenticate with. If you are using a 2FA, you will need use an access token: https://docs.docker.com/docker-hub/access-tokens/
```
-Credential <PSCredential>
    Represents the Docker Hub credentials to authenticate with. If you are using a 2FA, you will need use an access token: https://docs.docker.com/docker-hub/access-tokens/
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Username &lt;String&gt;
Represents the Docker Hub username to authenticate with.
```
-Username <String>
    Represents the Docker Hub username to authenticate with.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Password &lt;String&gt;
Represents the Docker Hub Password / Access Token to authenticate with. Learn more about access tokens: https://docs.docker.com/docker-hub/access-tokens/
```
-Password <String>
    Represents the Docker Hub Password / Access Token to authenticate with. Learn more about access tokens: https://docs.docker.com/docker-hub/access-tokens/
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ReturnAsObject &lt;SwitchParameter&gt;
Returns the output as a PSObject
```
-ReturnAsObject [<SwitchParameter>]
    Returns the output as a PSObject
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## EXAMPLES    
### EXAMPLE 1
```powershell
Get-DockerHubRateLimitStatus.ps1
```
Retrieves current rate limit status    

### EXAMPLE 2
```powershell
$cred = Get-Credential
Get-DockerHubRateLimitStatus.ps1 -Credential $cred -ReturnAsObject
```
Retrieves current rate limit status as an authenticated user and returns it as a PowerShell Object    

## NOTES
```
Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2020.11.29  Initial Release

Inspiration from: 
    * https://stackoverflow.com/questions/53176436/docker-image-statistics-from-hub-docker-com
```

## INPUTS


## OUTPUTS

