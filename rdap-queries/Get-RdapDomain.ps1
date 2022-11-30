#!/usr/bin/pwsh

# Copyright 2022 Cody Ernesti
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
    [String[]]$Domain,
    $BaseUri = "http://rdap-bootstrap.arin.net/bootstrap/domain/",
    [Switch]$Raw
)

Try{
    $d_results = @()
    $p_results = @()
    foreach($d in $domain){
        $result = Invoke-RestMethod $($BaseUri + $d)
        $d_results += $result

        # Get Expiration Date
        $expirationDate = ($result.events | ? eventAction -eq expiration).eventDate
        $seconds = [Math]::Round(($(Get-Date $expirationDate) - $(Get-Date)).TotalSeconds)
        
        $p_results += @{
            channel = "$d"
            value = $Seconds
            unit = "TimeSeconds"
            LimitMode = 1
            LimitMinWarning = 2592000
            LimitMinError = 604800
            LimitWarningMsg = "Domain is renewing within a month"
            LimitErrorMsg = "Domain needs to be renewed in the next 7 days"
        }
    }
    
    if($Raw){
        return $d_results
    }

    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = $p_results
        }
    }

    $returnObject | ConvertTo-Json -Depth 3

}catch{
    $returnObject = @{
        prtg = @{
            error = 2
            text = $_.Exception.Message
        }
    }
    $returnObject | ConvertTo-Json -Depth 3
}

<#
.SYNOPSIS
Retrieves Domain info in PRTG format

.DESCRIPTION
Creates PRTG sensor JSON with domain expiration retrieved from a defined rdap endpoint

.PARAMETER Domain
Domain to retrieve info about

.PARAMETER BaseUri
RDAP directory location

.PARAMETER Raw
View raw RDAP object

.EXAMPLE
Get-RdapDomain.ps1 -Domain "example.com" -Raw

.NOTES
Author:  Cody Ernesti
Version: 0.1
Version History:
    0.1  2022.11.03  Initial release

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors
#>