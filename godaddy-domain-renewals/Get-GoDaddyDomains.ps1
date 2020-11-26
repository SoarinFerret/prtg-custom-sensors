Param(
    [string]$DomainFilter = "*",
    [Parameter(ParameterSetName='pscred')]
    [PSCredential]$Credential,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$ApiKey,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$ApiSecret,
    [Switch]$IgnoreStatus,
    [Switch]$ReturnAsObject
)

try{
    # Authentication Headers
    $credential = if($PSCmdlet.ParameterSetName -eq "pscred"){ $Credential } else { New-Object PSCredential ($ApiKey,$($ApiSecret | ConvertTo-SecureString -AsPlainText -Force))}
    $headers = @{"Authorization" = "sso-key $($credential.GetNetworkCredential().UserName)`:$($credential.GetNetworkCredential().Password)"}

    # Get List of Domains
    $domains = Invoke-RestMethod -Headers $headers -Uri https://api.godaddy.com/v1/domains/

    if(!$IgnoreStatus){
        $domains = $domains | where {$_.Status -eq "ACTIVE" -or $_.Status -eq "EXPIRED"}
    }

    if($ReturnAsObject){
        return $domains | ? domain -like $DomainFilter
    }

    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    foreach($d in $domains | ? domain -like $DomainFilter){
        $returnObject.prtg.result += @{
            channel = "$($d.domain)"
            value = [math]::Round((New-TimeSpan -Start (Get-Date) -end $(get-date $d.expires)).totalseconds)
            Unit = "TimeSeconds"
            LimitMode = 1
            LimitMaxWarning = 2592000
            LimitMaxError = 604800
            LimitWarningMsg = "Domain is renewing within a month"
            LimitErrorMsg = "Domain needs to be renewed in the next 7 days"
        }
    }
    return $returnObject | ConvertTo-Json -Depth 3
}catch{
    $returnObject = @{
        prtg = @{
            error = 2
            text = $_.Exception.Message
        }
    }

    return $returnObject | ConvertTo-Json -Depth 3
}

<#
.SYNOPSIS
Retrieves the expiration for each GoDaddy domain under your account

.DESCRIPTION
Uses the GoDaddy API to retrieve information about your domains' expiration returned in a PRTG compatible format.

.PARAMETER DomainFilter
Optionally filter the output of the domains

.PARAMETER Credential
Provide the production API Key & Secret as a PSCredential Object

.PARAMETER ApiKey
Production API Key from GoDaddy

.PARAMETER ApiSecret
Production API Secret from GoDaddy

.PARAMETER IgnoreStatus
By default, this script only returns domains with an "ACTIVE" or "EXPRIED" status. This flag will return all domains

.PARAMETER ReturnAsObject
Returns the output as a PSObject with more information. Typically used for debugging.

.EXAMPLE
Get-GoDaddyDomains.ps1 -Credential (get-credential) -ReturnAsObject

Retrieves verbose details about all GoDaddy domains as PSObject

.EXAMPLE
Get-DockerHubStats.ps1 -ApiKey "xxxxx" -ApiSecret "xxxxx"

Returns PRTG compatible output

.NOTES

Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2020.11.26  Initial Release

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors

#>