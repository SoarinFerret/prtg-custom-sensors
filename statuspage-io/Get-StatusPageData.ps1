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


[CmdletBinding(DefaultParameterSetName="__AllParameterSets")]
Param(
    [parameter(Mandatory=$true)]
    [String]$Uri,
    
    [String[]]$ID,
    [String[]]$Name,
    
    [parameter(Mandatory=$false,ParameterSetName = "ExcludeMain")]
    [Switch]$ExcludeMainItems,

    [parameter(Mandatory=$false,ParameterSetName = "ExcludeSub")]
    [Switch]$ExcludeSubItems,
    
    [Switch]$PrependGroupNames,
    [Switch]$ReturnAsObjects
)

# valid status: operational, degraded_performance, partial_outage, or major_outage
function convertStatus($status){
     switch ($status) {
        "operational" { 1; break}
        "degraded_performance" {5; break}
        "partial_outage" {10; break}
        "major_outage" {11; break}
        default {20}
    }
}

try{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $raw = Invoke-RestMethod -Uri $Uri

    $returnItems = @()
    if($id){
        foreach($i in $id) {
            $returnItems += $raw.components | Where-Object {$_.id -eq $i -or $_.group_id -eq $i}
        }
    }
    
    if($Name){
        foreach($n in $name){
            $returnItems += $raw.components | Where-Object {$_.name -like $n}
        }
    }

    if(-not $id -and -not $Name){
        $returnItems = $raw.components
    }

    # Remove Sub / Main items if not specifically listed by ID
    if($ExcludeMainItems){
        $returnItems = $returnItems | Where-Object group_id -ne $null
    }elseif($ExcludeSubItems){
        $returnItems = $returnItems | Where-Object group_id -eq $null
    }

    # Optionally Prepend Group Names
    if($PrependGroupNames){
        foreach($item in $returnItems){
            if($null -ne $item.group_id){
                $group = ($raw.components | Where-Object group_id -eq $null | Where-Object id -eq $item.group_id).name
                # check if group happens to be same name as subitem (idk why, it happens)
                if($group -ne $item.name){
                    $item.name = $group + " - " + $item.name.replace($group, "")
                }else{
                    $item.name = $group + " - " + $item.name
                }
                
            }
        }
    }

    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    foreach($item in $returnItems | Sort-Object -Property Name){
        $returnObject.prtg.result += @{
            channel = $item.name
            value = convertStatus $item.status
            ValueLookup = "custom.statuspage.status"
        }
    }

    if($ReturnAsObjects){
        return $returnItems | Sort-Object -Property Name
    }

    return $returnObject | ConvertTo-Json -Depth 3
}
catch{
    if($ReturnAsObjects){
        Write-Error $_
    }else{
        $returnObject = @{
            prtg = @{
                error = 2
                text = $_.Exception.Message
            }
        }
        $returnObject | ConvertTo-Json -Depth 3
    }
}


<#
.SYNOPSIS
Parse StatusPage.io compatible JSON endpoint for use as a PRTG sensor

.DESCRIPTION
StatusPage.io webpages are a common format for companies to display data to users about system status. This script takes the JSON endpoint and delivers it to PRTG for long-term monitoring, reporting, and alerting.

.PARAMETER Uri
URI to get data. Usually ends with '/api/v2/components.json'

.PARAMETER ID
Optional ID of the specific component(s) you want. If the ID of a main item is selected, all subitems are included by default.

.PARAMETER Name
Optional Name of the component(s) you want. Wildcards are allowed. This does not automatically include any subitems of a mainitem.

.PARAMETER ExcludeMainItems
Exclude all main items, only including subitems

.PARAMETER ExcludeSubItems
Exclude all subitems, leaving only main items

.PARAMETER PrependGroupNames
Sometimes it is nice to prepend the Group Name to the same of the SubItem

.PARAMETER ReturnAsObjects
Useful for Debugging on the CLI

.EXAMPLE
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames

Returns all values, adding the group name to every entry. If the group name already exists, it moves it to the beginning of the line.

.EXAMPLE
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames -Name "*Dallas*","*Fremont*"

Only returns components with Dallas or Fremont in the title. Useful when you don't care about issues in other locations.

.EXAMPLE
Get-StatusPageDate.ps1 -Uri https://status.linode.com/api/v2/components.json -PrependGroupNames -ReturnAsObjects

Returns as an array of PSObjects. Useful for debugging.

.NOTES
For the lookup in PRTG to work you need to copy the file "custom.statuspage.status.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 0.1
Version History:
    0.1  2020.05.08  Initial release

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors

#>