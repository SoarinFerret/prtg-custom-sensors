<#
.SYNOPSIS
Retrives smartctl temperature data for all drives on a FreeNAS server

.DESCRIPTION
Retrives smartctl temperature data for all compatible drives on a FreeNAS server via SSH, and then returns it in JSON format suitable for PRTG

.PARAMETER ComputerName
Represents the FreeNAS server to connect to.

.PARAMETER Credential
Credentials used to connect to the FreeNAS server

.PARAMETER Username
Username to connect to server (for use in prtg)

.PARAMETER Password
Password to connect to server (for use in prtg)

.PARAMETER Port
SSH port on server

.EXAMPLE
Retrieves disk health for specified pool.
Get-FreeNASDiskHealth.ps1 -ComputerName "freenas" -Credential $(Get-Credential root)

.EXAMPLE
Retrieves disk health for specified pool using PRTG credentials
Get-FreeNASDiskTemps.ps1 -ComputerName "freenas" -Username '%linuxuser' -Password '%linuxpassword'

.NOTES
Requires Posh-SSH module to loaded in PowerShell

Author:  Cody Ernesti
Version: 1.0
Version History:
    1.0  2020.11.07  Initial release

.LINK
https://github.com/soarinferret/freenas-prtg-zpool-sensor

#>

Param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string]$ComputerName,
    [Parameter(ParameterSetName='pscred')]
    [PSCredential]$Credential,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Username,
    [Parameter(ParameterSetName='prtgcred')]
    [String]$Password,
    [ValidateNotNullOrEmpty()]
    [int32]$Port = 22
)

try{
    Import-Module Posh-SSH

    $credential = if($PSCmdlet.ParameterSetName -eq "pscred"){ $Credential } else { New-Object PSCredential ($username,$($password | ConvertTo-SecureString -AsPlainText -Force))}

    # Open Connection
    $session = New-SSHSession -ComputerName $ComputerName -Credential $Credential -Port $Port -AcceptKey

    # Get Drives
    $drives = $(Invoke-SSHCommand -Command "smartctl --scan | awk '{print `$1}'" -SSHSession $session).output

    ## Get Drive Temp
    $temps = @()
    foreach($drive in $drives){
        $script = "smartctl -A `"$drive`""
        $smartctl = $(Invoke-SSHCommand -Command $script -SSHSession $session).output

        if($line = ($smartctl | Select-String "194 Temperature")){
            $temp = ($line.ToString().trim() -split '\s+')[9]
        }
        elseif($line = ($smartctl | Select-String "190 Airflow_Temperature")){
            $temp = ($line.ToString().trim() -split '\s+')[9]
        }
        elseif($line = ($smartctl | Select-String "Current Drive Temperature")){
            $temp = ($line.ToString().trim() -split '\s+')[-1]
        }

        $temps += New-Object PSObject -Property @{'Drive'=$drive;'Temp'=$temp}
    }

    # Close Session
    Remove-SSHSession $session.SessionId


    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }
    foreach($d in $temps){
        $returnObject.prtg.result += @{
            channel = "$($d.drive) Temp"
            value = "$($d.temp)"
            unit = "Temperature"
            LimitMode = 1
            LimitMaxError = 45
            LimitMaxWarning = 40
            LimitMinError = 20
            LimitMinWarning = 25
            LimitWarningMsg = "Drive is approaching an unsafe temperature"
            LimitErrorMsg = "Drive has reached an unsafe temperature"
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