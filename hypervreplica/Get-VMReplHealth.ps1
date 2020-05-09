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

Param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $VMName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $ComputerName,
    [Parameter(ParameterSetName='pscred')]
    [PSCredential]$Credential,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Username,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Password
)
try{
    $credential = if($PSCmdlet.ParameterSetName -eq "pscred"){ $Credential } else { New-Object PSCredential ($username,$($password | ConvertTo-SecureString -AsPlainText -Force))}

    # Invoke command on remote Veeam Server (since there is no need to install the Veeam Snapin on prtg)
    $replhealth = icm -ComputerName $ComputerName -Credential $credential -ErrorAction Stop -ArgumentList $VMName -ScriptBlock { 
        $repl = Get-VMReplication $args[0]
        if($repl){
            return $repl
        }
        return 0
    }

    # If error
    if($replhealth -eq 0){
        throw "Unable to retrieve VM Replication Health info"
    }

    # OverallState determines overall job health
    # 0 means error, 1 means sucess, and 2 means warning
    $OverallState = 1
    if($replhealth.ReplicationHealth -eq "Warning"){$OverallState = 2}
    elseif($replhealth.ReplicationHealth -eq "Critical"){$OverallState = 0}

    # State is the current state of replication
    $state;
    if($replhealth.ReplicationState -like "Replicating"){$state = 100}
    elseif($replhealth.ReplicationState -like "Suspended"){$state = 200}
    elseif($replhealth.ReplicationState -like "Resynchronizing"){$state = 300}
    elseif($replhealth.ReplicationState -like "ResynchronizeSuspended"){$state = 400}
    elseif($replhealth.ReplicationState -like "SyncedReplicationComplete"){$state = 500}
    else{$state = 600}

    # Create XML Structure
    $xml = "<prtg>`n"
    $xml += "`t<result>`n`t`t<channel>Overall Health</channel>`n`t`t<ValueLookup>custom.vmreplhealth.state</ValueLookup>`n`t`t<value>$OverallState</value>`n`t</result>`n"
    $xml += "`t<result>`n`t`t<channel>Replication State</channel>`n`t`t<ValueLookup>custom.vmreplhealth.state</ValueLookup>`n`t`t<value>$state</value>`n`t</result>`n"
    $xml += "</prtg>"

    return $xml
}
catch{
    $xml = "<prtg>`n`t<error>1</error>`n`t<text>$_</text>`n</prtg>"
    return $xml
}

<#
.SYNOPSIS
Retrieves VM replication health in PRTG compatible format

.DESCRIPTION
The Get-VMReplHealth.ps1 creates a remote session to a Hyper-V Replication server to retrieve VM replication health status. The XML output can be used for a PRTG sensor.

.PARAMETER VMName 
Represents the name of the VM to get the health data for.

.PARAMETER ComputerName
Represents the Hyper-V server to connect to.

.PARAMETER Credential
Credentials used to connect to the Hyper-V server

.PARAMETER Username
Username to connect to server (for use in prtg)

.PARAMETER Password
Password to connect to server (for use in prtg)

.EXAMPLE
Retrieves VM Replication status for specified VM.
Get-VMReplHealth.ps1 -ComputerName "HyperVServer" -Credential $(New-PSCredential user) -VMName "AD"

.EXAMPLE
Retrieves Veeam backup status for specified job using PRTG credentials
Get-VMReplHealth.ps1 -ComputerName "HyperVServer" -Username '%windowsdomain\%windowsuser' -Password '%windowspassword' -VMName "AD"

.NOTES
For the lookup in PRTG to work you need to copy the file "custom.vmreplhealth.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2018.07.29  Initial release

.LINK
https://github.com/Soarinferret/prtg-custom-sensors

#>
