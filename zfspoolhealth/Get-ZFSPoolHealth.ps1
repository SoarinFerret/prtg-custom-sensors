<#
.SYNOPSIS
Retrives health data for a specifed zpool on a server running ZFS

.DESCRIPTION
Retrieves health data for appropriate mirrors, disks, and overall pool health via SSH, and returns it in JSON format suitable for PRTG

.PARAMETER ComputerName
Represents the server to connect to.

.PARAMETER Credential
Credentials used to connect to the server

.PARAMETER Username
Username to connect to server (for use in prtg)

.PARAMETER Password
Password to connect to server (for use in prtg)

.PARAMETER Port
SSH port on server

.PARAMETER Pool
Name of the zpool

.EXAMPLE
Retrieves disk health for specified pool.
Get-ZFSPoolHealth.ps1 -ComputerName "zol" -Credential $(Get-Credential root) -Pool "tank"

.EXAMPLE
Retrieves disk health for specified pool using PRTG credentials
Get-ZFSPoolHealth.ps1 -ComputerName "zol" -Username '%linuxuser' -Password '%linuxpassword' -Pool "tank"

.NOTES
Requires Posh-SSH module to loaded in PowerShell

For the lookup in PRTG to work you need to copy the file "custom.zfspoolhealth.state.ovl" to your PRTG installation folder (/lookups/custom/) of your core server and reload the lookups 
(Setup/System Administration/Administrative Tools -> Load Lookups).

Author:  Cody Ernesti
Version: 1.1
Version History:
    1.0  2018.10.28  Initial release
    1.1  2020.11.25  Updated for Generic ZFS server
                     Added option to override SSH key changes
    1.2  2020.11.26  Fixed Disk Output for ZoL

.LINK
https://github.com/soarinferret/prtg-custom-sensors

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
    [int32]$Port = 22,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [string][String]$Pool,
    [Switch]$OverrideOldKey
)

try{

    Import-Module Posh-SSH

    $credential = if($PSCmdlet.ParameterSetName -eq "pscred"){ $Credential } else { New-Object PSCredential ($username,$($password | ConvertTo-SecureString -AsPlainText -Force))}

    # Override Old Key
    if($overrideoldkey){
        Get-SSHTrustedHost | Remove-SSHTrustedHost
    }

    # Open Connection
    $session = New-SSHSession -ComputerName $ComputerName -Credential $Credential -Port $Port -AcceptKey

    # Get Data
    ## Get pool capacity
    $capacity = $(Invoke-SSHCommand -Command "zpool list -H -o capacity $pool" -SSHSession $session).output

    ## Get Disks in Pool Health
    $diskhealthraw = (Invoke-SSHCommand -Command "zpool status -v $pool" -SSHSession $session).output

    # Close Session
    Remove-SSHSession $session.SessionId

    # Format Pool Output
    $poolhealth = $diskhealthraw[1].Replace(" state: ","")

    # Format Disk Output
    $diskhealth = @{}
    $mirrorhealth = @{}

    ## extrapolate data
    $x = $diskhealthraw.IndexOf("config:")
    $lastmirror = ""
    $diskhealthraw[($x + 4)..($diskhealthraw.Length -3)] | ConvertFrom-String | % {
        if ($_.P2 -like "mirror*"){
            $mirrorhealth.Add($_.P2, $_.P3)
            $lastmirror = $_.P2
        }
        else{
            $diskhealth.Add("$lastmirror - $($_.P2)",$_.P3)
        }
    }

    #Format PRTG Output
    function get-ovlvalue([String]$state){
        if($state -like "FAULTED"){ return 0 }
        elseif($state -like "ONLINE"){ return 1 }
        elseif($state -like "DEGRADED"){ return 2 }
        elseif($state -like "UNAVAIL"){ return 3 }
        elseif($state -like "OFFLINE"){ return 4 }
        elseif($state -like "REMOVED"){ return 5 }
    }


    # PRTG Return
    $returnObject = @{
        prtg = @{
            result = @()
        }
    }

    # Add Overall Health Channel
    $returnObject.prtg.result += @{
        channel = "Pool Health"
        value = $(get-ovlvalue $poolhealth)
        ValueLookup = "custom.zfspoolhealth.state"
    }

    #TODO: add capacity to output

    # Mirror Health
    $mirrorhealth.GetEnumerator() | Sort-Object -Property Name | % {
        $returnObject.prtg.result += @{
            channel = $_.Name
            value = $(get-ovlvalue $_.Value)
            ValueLookup = "custom.zfspoolhealth.state"
        }
    }

    # Disk Health
    $diskhealth.GetEnumerator() | Sort-Object -Property Name | % {
        $returnObject.prtg.result += @{
            channel = $_.Name
            value = $(get-ovlvalue $_.Value)
            ValueLookup = "custom.zfspoolhealth.state"
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