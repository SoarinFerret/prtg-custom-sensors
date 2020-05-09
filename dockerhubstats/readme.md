# ./Get-DockerHubStats.ps1

## SYNOPSIS
Retrieves stats about a image hosted in Docker Hub in a PRTG Compatible format

## SYNTAX
```powershell
./Get-DockerHubStats.ps1 [-DockerImage] <String> [-ReturnAsObject] [<CommonParameters>]
```

## DESCRIPTION
Uses the docker hub API to generate PRTG compatible statistics

## PARAMETERS
### -DockerImage &lt;String&gt;
Name of the image you want to moniter in a "repo/image" format
```
-DockerImage <String>
    Name of the image you want to moniter in a "repo/image" format
    
    Required?                    true
    Position?                    1
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

## NOTES
```
Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2019.08.30  Initial Release

Inspiration from: 
    * https://stackoverflow.com/questions/53176436/docker-image-statistics-from-hub-docker-com
```

## INPUTS


## OUTPUTS


## EXAMPLES
### EXAMPLE 1
```powershell
Get-DockerHubStats.ps1 -DockerImage "library/ubuntu"
```
Retrieves stats for specified repository.    
 
### EXAMPLE 2
```powershell
Get-DockerHubStats.ps1 -DockerImage "library/ubuntu" -ReturnAsObject
```
Retrieves stats for specified repository and returns it as a PowerShell Object    

