#!/usr/bin/pwsh
# Copyright 2021 Cody Ernesti
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
    [String]$ComputerName,
    [Parameter(ParameterSetName = "SecureCreds")]
    [pscredential]$Credential,
    [Parameter(ParameterSetName = "PlainTextPassword")]
    [string]$Username,
    [Parameter(ParameterSetName = "PlainTextPassword")]
    [String]$Password,
    [String]$AdomName
)

function Connect-FortiAnalyzer {
    [CmdletBinding()]
    Param(
        $FortiAnalyzer,
        $Credential
    )


    $postParams = @{
        method = "exec";
        params = @(@{ 
            data = @{  
                passwd = $credential.GetNetworkCredential().Password;
                user=$Credential.UserName
            };
            url = "/sys/login/user"
        });
        id = 1;
    }
    try{
        #splat arguments
        $splat = @{
            Uri = "https://$FortiAnalyzer/jsonrpc";
            Method = 'POST';
            Body = $postParams | ConvertTo-Json -Depth 4
            headers = @{"Content-Type" = "application/json"}
        }
        if($PSEdition -eq "Core"){$splat.Add("SkipCertificateCheck",$true)}

        $authRequest = Invoke-RestMethod @splat

        if($authRequest.result.status.code -ne 0 ){
            throw "Code: $($authRequest.result.status.code)`tMessage: $($authRequest.result.status.message)"
        }

    }catch{
        throw "Failed to authenticate to FortiAnalyzer with error: `n`t$_"
    }


    Set-Variable -Scope Global -Name "FazServer" -Value $FortiAnalyzer
    Set-Variable -Scope Global -Name "FazSession" -Value $authRequest.session
}

function Invoke-FazRestMethod {
    [CmdletBinding()]
    Param(
        $RpcMethod = "get",
        $Params = $null,
        [String]$JsonRPCVersion
    )

    #Update-Logs -Message "Invoke Rest - Building Headers" 
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Accept','application/json')
    $headers.Add('Content-Type','application/x-www-form-urlencoded')
    # Add csrf cookie
    #$headers.Add('X-CSRFTOKEN',$FgtCSRFToken)

    $postParams = @{
        method = $RpcMethod;
        params = @($Params);
        session = $FazSession;
        id = 1;
    }

    if($JsonRPCVersion){
        $postParams.Add("jsonrpc", $JsonRPCVersion)
    }

    Write-Verbose $($postParams | ConvertTo-Json -Depth 5)

    $splat = @{
        Headers = $headers;
        Uri = "https://$FazServer/jsonrpc";
        Method = "POST";
        Body = $postParams | ConvertTo-Json -Depth 5
    }
    if($PSEdition -eq "Core"){$splat.Add("SkipCertificateCheck",$true)}
    return Invoke-RestMethod @splat
}

function Get-FazStatus {
    return (Invoke-FazRestMethod -Params @{url="/sys/status"}).result.data
}

function Get-FazAdom {
    return (Invoke-FazRestMethod -Params @{url="/dvmdb/adom"}).result.data
}

function Get-FazDevice {
    Param(
        $AdomName
    )

    return (Invoke-FazRestMethod -Params @{url="/dvmdb/adom/$AdomName/device"}).result.data 
}

# only returns information about devices w/ vdoms actively logging to the FAZ
function Get-FazFgtLogDetails {
    Param(
        $AdomName
    )

    return (Invoke-FazRestMethod -Params @{'url' = "/logview/adom/$AdomName/logstats"; 'device' = @(@{'devid'="All_FortiGate"}); apiver = 3} -JsonRPCVersion "2.0").result.data
}

function Disconnect-FortiAnalyzer {
    [CmdletBinding()]
    param()
    
    $logoutrequest = Invoke-FazRestMethod -RpcMethod "exec" -Params @{url="/sys/logout"}

    Remove-Variable -Scope Global -Name "FazServer"
    Remove-Variable -Scope Global -Name "FazSession" 
    return $logoutRequest
}

# Set TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if($PSCmdlet.ParameterSetName -eq "PlainTextPassword"){
    #Write-Warning "You shouldn't use plaintext passwords on the commandline"
    [securestring]$secStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($Username, $secStringPassword)
}

try{
    Connect-FortiAnalyzer -FortiAnalyzer $ComputerName -Credential $Credential 
    $devices = @()
    $loginfo = @()
    if($AdomName){
        $devices += Get-FazDevice -AdomName $AdomName
        $loginfo += Get-FazFgtLogDetails -AdomName $AdomName
    }else{
        $adoms = Get-FazAdom
        foreach($adom in $adoms){
            $devices += Get-FazDevice -AdomName $adom.name
            $loginfo += Get-FazFgtLogDetails -AdomName $adom.name
        }
    }

    $logoutreturn = Disconnect-FortiAnalyzer

    $returnObject = @{
        prtg = @{
            result = @()
        }
    }
    
    foreach($device in $devices){
        $value = 2
        if($loginfo | ? devid -eq $device.sn){$value = 1}
        $returnObject.prtg.result += @{
            channel = "$($device.Name)"
            value = $value
            Unit = "Custom"
            ValueLookup = "prtg.standardlookups.activeinactive.stateactiveok"
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
This is a simple Powershell script to pull Device Status from a FortiAnalyzer

.DESCRIPTION
This script uses the FortiAnalyzer JSON-RPC API to pull the logging status of each device connected to the FortiAnalyzer.

.PARAMETER ComputerName
Represents the FortiAnalyzer to connect to. The Fortianalyzer must be at least version 6.4.

.PARAMETER Credential
Credentials used to connect to the FortiAnalyzer. Make sure the user has JSON API Access enabled

.PARAMETER Username
Username to connect to server (for use in prtg)

.PARAMETER Password
Password to connect to server (for use in prtg)

.PARAMETER AdomName
Limit the devices returned by Adom

.EXAMPLE
Returns the devices by a specified ADOM
Get-FazDeviceStatus.ps1 -ComputerName "faz.example.com" -Credential (get-credential root) -AdomName "TEST"

.NOTES
Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2021.02.08  Initial release
    1.1  2021.02.11  More reliable check using '/logview/logstats'

.LINK
https://github.com/soarinferret/prtg-custom-sensors
#>
