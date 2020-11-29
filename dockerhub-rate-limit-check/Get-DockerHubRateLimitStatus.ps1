#!/usr/bin/pwsh
# Copyright 2020 Cody Ernesti
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding(DefaultParametersetname="PSCred")]
Param(
    [Parameter(ParameterSetName='pscred')]
    [PSCredential]$Credential,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Username,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Password,
    [switch]$ReturnAsObject
)
try{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $params = @{}
    if($Credential -or $username){
        $credential = if($PSCmdlet.ParameterSetName -eq "pscred"){ $Credential } else { New-Object PSCredential ($username,$($password | ConvertTo-SecureString -AsPlainText -Force))}
        if($PSEdition -eq "Core"){
            $params.Add("Authentication", "Basic")
            $params.add("Credential", $Credential)
        }else{
            $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
            $params.Add("Headers", @{Authorization=("Basic {0}" -f $base64AuthInfo)})
        }
        
    }

    # be sure to set the user agent to curl so it doesn't *always* (?) count against your number of pulls
    $token = (Invoke-RestMethod "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" -UserAgent "curl/7.68.0" -UseBasicParsing @params).token
    $details = Invoke-WebRequest -Headers @{"Authorization"="Bearer $token"} -Uri "https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest" -UserAgent "curl/7.68.0" -UseBasicParsing
}catch{
    if(!$ReturnAsObject){
        $returnObject = @{
            prtg = @{
                error = 2
                text = $_.Exception.Message
            }
        }
    
        return $returnObject | ConvertTo-Json -Depth 3
    }
    else{
        throw $_
    }
}

if(!$ReturnAsObject){
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    $returnObject.prtg.result += @{
        channel = "Rate Limit Pulls Remaining"
        value = $details.Headers['RateLimit-Remaining'].split(";")[0]
        Unit = "Count"
        LimitMode = 1
        LimitMinError = 15
        LimitMinWarning = 30
    }

    $returnObject.prtg.result += @{
        channel = "Rate Limit Total Number of Pulls"
        value = $details.Headers['RateLimit-Limit'].split(";")[0]
        Unit = "Count"
    }

    $returnObject.prtg.result += @{
        channel = "Rate Limit Time Period (Seconds)"
        value = [int32]$details.Headers['RateLimit-Limit'].split(";")[1].replace("w=","")
        Unit = "Count"
    }

    return $returnObject | ConvertTo-Json -Depth 3
}else{
    return New-Object psobject -Property @{
        RateLimitPullsRemaining=$details.Headers['RateLimit-Remaining'].split(";")[0]
        RateLimitTotalPulls=$details.Headers['RateLimit-Limit'].split(";")[0]
        TimeSpan=[TimeSpan]::fromseconds([int32]$details.Headers['RateLimit-Limit'].split(";")[1].replace("w=",""))
    }
}



<#
.SYNOPSIS
Retrieves current Docker Hub rate limit in a PRTG Compatible format

.DESCRIPTION
Uses the docker hub API to generate PRTG compatible statistics about the current rate limit status. Optionally can use Docker Hub credentials.

.PARAMETER Credential
Represents the Docker Hub credentials to authenticate with. If you are using a 2FA, you will need use an access token: https://docs.docker.com/docker-hub/access-tokens/

.PARAMETER Username
Represents the Docker Hub username to authenticate with.

.PARAMETER Password
Represents the Docker Hub Password / Access Token to authenticate with. Learn more about access tokens: https://docs.docker.com/docker-hub/access-tokens/

.PARAMETER ReturnAsObject
Returns the output as a PSObject

.EXAMPLE
Get-DockerHubRateLimitStatus.ps1

Retrieves current rate limit status

.EXAMPLE
$cred = Get-Credential
Get-DockerHubRateLimitStatus.ps1 -Credential $cred -ReturnAsObject

Retrieves current rate limit status as an authenticated user and returns it as a PowerShell Object

.NOTES

Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2020.11.29  Initial Release

Inspiration from: 
    * https://stackoverflow.com/questions/53176436/docker-image-statistics-from-hub-docker-com

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors

#>