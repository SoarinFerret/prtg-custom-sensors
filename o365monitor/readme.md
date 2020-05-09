# ./Get-Office365Status.ps1

## SYNOPSIS
Retrieves current service information from Office 365 tenant in PRTG compatible format

## SYNTAX
```powershell
./Get-Office365Status.ps1 [-ClientID] <String> [-ClientSecret] <String> [-TenantIdentifier] <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-Office365Status.ps1 uses Microsofts REST api to get the current health status of your Office 365 tenant. The XML output can be used as PRTG custom sensor.

## PARAMETERS
### -ClientID &lt;String&gt;
Represents the ClientId that is used to connect to your Office 365 tenant. See NOTES section for more details.
```
-ClientID <String>
    Represents the ClientId that is used to connect to your Office 365 tenant. See NOTES section for more details.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -ClientSecret &lt;String&gt;
Represents the corresponding client secret to connect to your Office 365 tenant. See NOTES section for more details.
```
-ClientSecret <String>
    Represents the corresponding client secret to connect to your Office 365 tenant. See NOTES section for more details.
    
    Required?                    true
    Position?                    2
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```
 
### -TenantIdentifier &lt;String&gt;
Represents the tenant to be monitored. Not the tenant name used in your Office 365 URL (e.g. https://yourtenant.onmicrosoft.com)
```
-TenantIdentifier <String>
    Represents the tenant to be monitored. Not the tenant name used in your Office 365 URL (e.g. https://yourtenant.onmicrosoft.com)
    
    Required?                    true
    Position?                    3
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## NOTES
```
Your tenant needs to be prepared to access the health information. Detailed configuration guidance can be found under http://www.team-debold.de/2016/07/22/prtg-office-365-status-ueberwachen/
For the lookup in PRTG to work you need to copy the file "custom.office365.value.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Marc Debold
Version: 1.1
Version History:
    1.1  06.08.2016  Corrected naming mismatch in ovl file (thanks to playordie)
                     Added -UseBasicParsing Parameter to Invoke-WebRequest to bypass uninitialized Internet Explorer (thanks to playordie)
    1.0  22.07.2016  Initial release

For further reading:
    Result definition for service health: https://samlman.wordpress.com/2016/03/18/the-office365mon-rest-apis-continue-to-grow/
    PowerShell Snippets for O365 health monitoring: https://github.com/OfficeDev/O365-InvestigationTooling/blob/master/O365InvestigationDataAcquisition.ps1
    Prerequisites for O365 monitoring: https://msdn.microsoft.com/EN-US/library/office/dn707383.aspx
    More information about prerequisites: https://azure.microsoft.com/de-de/documentation/articles/active-directory-application-objects/#BKMK_AppObject
    O365 tenant id: https://support.office.com/de-de/article/Suchen-Ihrer-Office-365-Mandanten-ID-6891b561-a52d-4ade-9f39-b492285e2c9b
```

## INPUTS


## OUTPUTS


## EXAMPLES
### EXAMPLE 1
```powershell
Get-Office365Status.ps1 -ClientId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -ClientSecret "StrongPasswordFromAzureActiveDirectory" -TenantIdentifier "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj"
```
Retrieves Office 365 health information for specified tenant.
    

