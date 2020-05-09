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
    $Date,
    $ChannelName,
    [Switch]$CountUp
)

Try{
    if($CountUp){
        $Seconds = [Math]::Round(($(Get-Date) - $(Get-Date $date)).TotalSeconds)
    }else{
        $Seconds = [Math]::Round(($(Get-Date $date) - $(Get-Date)).TotalSeconds)
    }
    # don't be negative now ;)
    $Seconds = [math]::max(0, $Seconds)

    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    if(-not $ChannelName -and $CountUp){
        $ChannelName = "Time Since"
    }elseif(-not $ChannelName){
        $ChannelName = "Time Left"
    }

    $returnObject.prtg.result += @{
        channel = $ChannelName
        value = $Seconds
        unit = "TimeSeconds"
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
Creates either counters or countdowns for PRTG

.DESCRIPTION
Creates either counters or countdowns for PRTG

.PARAMETER Date
Date in which to compare. If comparison results in a negative number, it is changed to 0

.PARAMETER ChannelName
Optionally rename the channel. Defaults to "Time Left" or "Time Since" depending on CountDown or CountUp functionality

.PARAMETER CountUp
Switch to countup

.EXAMPLE
Get-PRTGSeconds.ps1 -Date 10/31/20 -ChannelName "Expiration Date"

.NOTES
Author:  Cody Ernesti
Version: 0.1
Version History:
    0.1  2019.04.02  Initial release

.LINK
https://github.com/SoarinFerret/prtg-custom-sensors
#>