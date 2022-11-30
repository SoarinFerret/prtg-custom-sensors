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

[cmdletbinding(DefaultParameterSetName='PSCreds')]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Fortigate,
    [Parameter(ParameterSetName="PSCreds",Mandatory = $true)]
    [pscredential]$Credential,
    [Parameter(ParameterSetName="PlainTextCreds",Mandatory = $true)]
    [String]$Username,
    [Parameter(ParameterSetName="PlainTextCreds",Mandatory = $true)]
    [String]$Password,
    [Switch]$ReturnAsPrtg
)


function Use-SelfSignedCerts {
    if($PSEdition -ne "Core"){
        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class PolicyCert : ICertificatePolicy {
                public PolicyCert() {}
                public bool CheckValidationResult(
                    ServicePoint sPoint, X509Certificate cert,
                    WebRequest wRequest, int certProb) {
                    return true;
                }
            }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object PolicyCert
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    }else{
        Write-Warning -Message "Function not supported in PSCore. Just use the '-SkipCertificateCheck' flag"
    }
}

function Connect-Fortigate {
    Param(
        $Fortigate,
        $Credential
    )

    $postParams = @{username=$Credential.UserName;secretkey=$Credential.GetNetworkCredential().Password}
    try{
        Write-Verbose "Authenticating to 'https://$Fortigate/logincheck' with username: $($Credential.UserName)"

        #splat arguments
        $splat = @{
            Uri = "https://$Fortigate/logincheck";
            SessionVariable = "session";
            Method = 'POST';
            Body = $postParams;
            UseBasicParsing = $true;
        }
        if($PSEdition -eq "Core"){$splat.Add("SkipCertificateCheck",$true)}

        $authRequest = Invoke-WebRequest @splat
    }catch{
        throw "Failed to authenticate to Fortigate with error: `n`t$_"
    }
    Write-Verbose "Authentication successful!"
    $csrftoken = ($authRequest.Headers['Set-Cookie'] | where {$_ -like "ccsrftoken=*"}).split('"')[1]

    Set-Variable -Scope Global -Name "FgtServer" -Value $Fortigate
    Set-Variable -Scope Global -Name "FgtSession" -Value $session
    Set-Variable -Scope Global -Name "FgtCSRFToken" -Value $csrftoken
}

function Invoke-FgtRestMethod {
    Param(
        $Endpoint,
        [ValidateSet("Default","Delete","Get","Head","Merge","Options","Patch","Post","Put","Trace")]
        $Method = "Get",
        $Body = $null
    )

    Write-Verbose "Building Headers"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Accept','application/json')
    $headers.Add('Content-Type','application/x-www-form-urlencoded')
    # Add csrf cookie
    $headers.Add('X-CSRFTOKEN',$FgtCSRFToken)

    $splat = @{
        Headers = $headers;
        Uri = "https://$FgtServer/api/v2/$($Endpoint.TrimStart('/'))";
        WebSession = $FgtSession;
        Method = $Method;
        Body = $body | ConvertTo-Json;
        UseBasicParsing = $true
    }
    if($PSEdition -eq "Core"){$splat.Add("SkipCertificateCheck",$true)}
    return Invoke-RestMethod @splat
}

function Disconnect-Fortigate {
    Write-Verbose "Building Headers"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Accept','application/json')
    $headers.Add('Content-Type','application/x-www-form-urlencoded')
    # Add csrf cookie
    $headers.Add('X-CSRFTOKEN',$FgtCSRFToken)
    
    # logout
    $splat = @{
        Headers = $headers;
        Uri = "https://$FgtServer/logout";
        WebSession = $fgtSession;
        Method = "GET"
        UseBasicParsing = $true
    }
    if($PSEdition -eq "Core"){$splat.Add("SkipCertificateCheck",$true)}
    $logoutRequest = Invoke-RestMethod @splat

    Remove-Variable -Scope Global -Name "FgtServer"
    Remove-Variable -Scope Global -Name "FgtSession" 
    Remove-Variable -Scope Global -Name "FgtCSRFToken"
    return $logoutRequest
}


if($PSCmdlet.ParameterSetName -ne "PSCreds"){
    #build creds
    $Credential = New-Object pscredential $Username,$($Password | ConvertTo-SecureString -AsPlainText -Force)
}

# Allow use of self signed certs
if($PSEdition -ne "Core"){
    Use-SelfSignedCerts
}

try{
    Write-Verbose "Authenticating to Fortigate"
    Connect-Fortigate -Fortigate $Fortigate -Credential $Credential
}catch{
    if($ReturnAsPrtg){
        $returnObject = @{
            prtg = @{
                error = 2
                text = $_.Exception.Message
            }
        }
    
        return $returnObject | ConvertTo-Json -Depth 3
    }
    else{
        throw "Failed to authenticate to $Fortigate with error:`n`t$_"
    }
}

try{
    Write-Verbose "Retrieving Registration Details"
    $request = Invoke-FgtRestMethod -Endpoint "monitor/license/status/select/"
}catch{
    if($ReturnAsPrtg){
        $returnObject = @{
            prtg = @{
                error = 2
                text = $_.Exception.Message
            }
        }
    
        return $returnObject | ConvertTo-Json -Depth 3
    }
    else{
        throw "Failed to retrieve registration details with error:`n`t$_"
    }
}

try{
    Write-Verbose "Disconnecting from Fortigate"
    Disconnect-Fortigate | Out-Null
}catch{}

if($ReturnAsPrtg){
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    $returnObject.prtg.result += @{
        channel = "UTM Expires In"
        value = [math]::Round((New-TimeSpan -Start ([datetime]'1/1/1970').AddSeconds($request.results.web_filtering.expires) -end $(get-date)).totalseconds)
        Unit = "TimeSeconds"
        LimitMode = 1
        LimitMinWarning = 2592000
        LimitMinError = 1209600
    }


    return $returnObject | ConvertTo-Json -Depth 3
}else{
    return ([datetime]'1/1/1970').AddSeconds($request.results.web_filtering.expires)
}