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
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $JobName,
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
    $vms = icm -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop -ArgumentList $JobName -ScriptBlock {
        Add-PSSnapin VeeamPSSnapin
        $Job = Get-VBRJob -Name $args[0] -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue'
        if($Job){
            $Session = $job.FindLastSession()
            return $vms = $session.GetTaskSessions() | select Name,Status
        }
        return 0
    }

    # If error
    if($vms -eq 0){
        throw "Unable to retrieve job info"
    }

    # OverallState determines overall job health
    # 0 means error, 1 means sucess, and 2 means warning
    $OverallState = 1
    if($vms.Status.value -contains "Success" -and $vms.Status.value -contains "Failed"){$OverallState = 2}
    elseif($vms.Status.value -notcontains "Success" -and $vms.Status.value -notcontains "Failed"){$OverallState = 2}
    elseif($vms.Status.value -notcontains "Success"){$OverallState = 0}

    # Create XML Structure
    $xml = "<prtg>`n"
    $xml += "`t<result>`n`t`t<channel>$JobName</channel>`n`t`t<ValueLookup>custom.veeam.state</ValueLookup>`n`t`t<value>$OverallState</value>`n`t</result>`n"
    $vms | % {
        $state = 0;
        if($_.Status.Value -like "Success"){$state = 1};
        if($_.Status.Value -like "Warning"){$state = 2};
        $xml += "`t<result>`n`t`t<channel>$($_.Name)</channel>`n`t`t<ValueLookup>custom.veeam.state</ValueLookup>`n`t`t<value>$state</value>`n`t</result>`n"
    }
    $xml += "</prtg>"

    return $xml
}
catch{
    $xml = "<prtg>`n`t<error>1</error>`n`t<text>$_</text>`n</prtg>"
    return $xml
}

<#
.SYNOPSIS
Retrieves Veeam job status in PRTG compatible format

.DESCRIPTION
The Get-VeeamBackupStatus.ps1 creates a remote session to a Veeam Backup & Replication server to retrieve job status. Every VM backed up in the job is listed as a channel. The XML output can be used for a PRTG sensor.

.PARAMETER JobName 
Represents the name of the job in Veeam to get the information from.

.PARAMETER ComputerName
Represents the Veeam server to connect to.

.PARAMETER Credential
Credentials used to connect to the Veeam server

.PARAMETER Username
Username to connect to server (for use in prtg)

.PARAMETER Password
Password to connect to server (for use in prtg)

.EXAMPLE
Retrieves Veeam backup status for specified job.
Get-VeeamBackupStatus.ps1 -ComputerName "VeeamServer" -Credential $(New-PSCredential user) -JobName "Accounting VMs"

.EXAMPLE
Retrieves Veeam backup status for specified job using PRTG credentials
Get-VeeamBackupStatus.ps1 -ComputerName "VeeamServer" -Username '%windowsdomain\%windowsuser' -Password '%windowspassword' -JobName "Accounting VMs"

.NOTES
For the lookup in PRTG to work you need to copy the file "custom.veeam.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.2
Version History:
    1.2  2019.01.24  Add option Warning for single VM
    1.1  2018.07.29  Added PRTG Credential Option
    1.0  2018.06.07  Initial release

.LINK
https://github.com/esutwo/prtg-sensors

#>