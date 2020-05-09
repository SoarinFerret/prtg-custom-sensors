#!/usr/bin/pwsh
# Copyright 2019 Cody Ernesti
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

Param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$DockerImage,
    [switch]$ReturnAsObject
)
try{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Details = Invoke-RestMethod -Method Get https://hub.docker.com/v2/repositories/$dockerimage -ErrorAction Stop
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
        channel = "Number of Pulls"
        value = $Details.pull_count
        Unit = "Count"
    }

    $returnObject.prtg.result += @{
        channel = "Number of Stars"
        value = $Details.star_count
        Unit = "Count"
    }

    $returnObject.prtg.result += @{
        channel = "Last updated"
        value = [math]::Round((New-TimeSpan -Start $(get-date $Details.last_updated) -end $(get-date)).totalseconds)
        Unit = "TimeSeconds"
        LimitMode = 1
        LimitMaxWarning = 2592000
    }

    return $returnObject | ConvertTo-Json -Depth 3
}else{
    return New-Object psobject -Property @{
        Image=$Details.name
        Namespace=$Details.Namespace
        Description=$Details.Description
        User=$Details.user
        Pulls=$Details.pull_count
        Stars=$Details.star_count
        "Last Updated"=$(get-date $Details.last_updated)
    }
}



<#
.SYNOPSIS
Retrieves stats about a image hosted in Docker Hub in a PRTG Compatible format

.DESCRIPTION
Uses the docker hub API to generate PRTG compatible statistics

.PARAMETER DockerImage
Name of the image you want to moniter in a "repo/image" format

.PARAMETER ReturnAsObject
Returns the output as a PSObject

.EXAMPLE
Get-DockerHubStats.ps1 -DockerImage "library/ubuntu"

Retrieves stats for specified repository.

.EXAMPLE
Get-DockerHubStats.ps1 -DockerImage "library/ubuntu" -ReturnAsObject

Retrieves stats for specified repository and returns it as a PowerShell Object

.NOTES

Author:     Cody Ernesti
Version:    0.1
Changelog:  
        0.1  2019.08.30  Initial Release

Inspiration from: 
    * https://stackoverflow.com/questions/53176436/docker-image-statistics-from-hub-docker-com

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors

#>