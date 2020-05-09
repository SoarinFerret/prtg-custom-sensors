# ./Get-SecondsCount.ps1

## SYNOPSIS
Creates either counters or countdowns for PRTG

## SYNTAX
```powershell
./Get-SecondsCount.ps1 [[-Date] <Object>] [[-ChannelName] <Object>] [-CountUp] [<CommonParameters>]
```

## DESCRIPTION
Creates either counters or countdowns for PRTG

## PARAMETERS
### -Date &lt;Object&gt;
Date in which to compare. If comparison results in a negative number, it is changed to 0
```
-Date <Object>
    Date in which to compare. If comparison results in a negative number, it is changed to 0
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ChannelName &lt;Object&gt;
Optionally rename the channel. Defaults to "Time Left" or "Time Since" depending on CountDown or CountUp functionality
```
-ChannelName <Object>
    Optionally rename the channel. Defaults to "Time Left" or "Time Since" depending on CountDown or CountUp functionality
    
    Required?                    false
    Position?                    2
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -CountUp &lt;SwitchParameter&gt;
Switch to countup
```
-CountUp [<SwitchParameter>]
    Switch to countup
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## NOTES
```
Author:  Cody Ernesti
Version: 0.1
Version History:
    0.1  2019.04.02  Initial release
```

## INPUTS


## OUTPUTS


## EXAMPLES
### EXAMPLE 1
```powershell
Get-PRTGSeconds.ps1 -Date 10/31/20 -ChannelName "Expiration Date"
```
    

