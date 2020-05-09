# ./Get-StatusPageData.ps1

## SYNOPSIS
Parse StatusPage.io compatible JSON endpoint for use as a PRTG sensor

## SYNTAX
```powershell
./Get-StatusPageData.ps1 -Uri <String> [-ID <String[]>] [-Name <String[]>] [-PrependGroupNames] [-ReturnAsObjects] [<CommonParameters>]

./Get-StatusPageData.ps1 -Uri <String> [-ID <String[]>] [-Name <String[]>] [-ExcludeMainItems] [-PrependGroupNames] [-ReturnAsObjects] [<CommonParameters>]

./Get-StatusPageData.ps1 -Uri <String> [-ID <String[]>] [-Name <String[]>] [-ExcludeSubItems] [-PrependGroupNames] [-ReturnAsObjects] [<CommonParameters>]
```

## DESCRIPTION
StatusPage.io webpages are a common format for companies to display data to users about system status. This script takes the JSON endpoint and delivers it to PRTG for long-term monitoring, reporting, and alerting.

## PARAMETERS
### -Uri &lt;String&gt;
URI to get data. Usually ends with '/api/v2/components.json'
```
-Uri <String>
    URI to get data. Usually ends with '/api/v2/components.json'
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ID &lt;String[]&gt;
Optional ID of the specific component(s) you want. If the ID of a main item is selected, all subitems are included by default.
```
-ID <String[]>
    Optional ID of the specific component(s) you want. If the ID of a main item is selected, all subitems are included by default.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -Name &lt;String[]&gt;
Optional Name of the component(s) you want. Wildcards are allowed. This does not automatically include any subitems of a mainitem.
```
-Name <String[]>
    Optional Name of the component(s) you want. Wildcards are allowed. This does not automatically include any subitems of a mainitem.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ExcludeMainItems &lt;SwitchParameter&gt;
Exclude all main items, only including subitems
```
-ExcludeMainItems [<SwitchParameter>]
    Exclude all main items, only including subitems
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ExcludeSubItems &lt;SwitchParameter&gt;
Exclude all subitems, leaving only main items
```
-ExcludeSubItems [<SwitchParameter>]
    Exclude all subitems, leaving only main items
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -PrependGroupNames &lt;SwitchParameter&gt;
Sometimes it is nice to prepend the Group Name to the same of the SubItem
```
-PrependGroupNames [<SwitchParameter>]
    Sometimes it is nice to prepend the Group Name to the same of the SubItem
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ReturnAsObjects &lt;SwitchParameter&gt;
Useful for Debugging on the CLI
```
-ReturnAsObjects [<SwitchParameter>]
    Useful for Debugging on the CLI
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## INPUTS


## OUTPUTS


## NOTES
```
For the lookup in PRTG to work you need to copy the file "custom.statuspage.status.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 0.1
Version History:
    0.1  2020.05.08  Initial release
```

## EXAMPLES
### EXAMPLE 1
```powershell
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames
```
Returns all values, adding the group name to every entry. If the group name already exists, it moves it to the beginning of the line.    
 
### EXAMPLE 2
```powershell
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames -Name "*Dallas*","*Fremont*"
```
Only returns components with Dallas or Fremont in the title. Useful when you don't care about issues in other locations.    
 
### EXAMPLE 3
```powershell
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames -ReturnAsObjects
```
Returns as an array of PSObjects. Useful for debugging.    

