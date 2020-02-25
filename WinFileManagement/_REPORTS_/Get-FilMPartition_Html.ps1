#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with all partition objects visible on the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT  
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_REPORTS_

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the partition informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
$Script:output = @()
try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }         
    Get-Volume  -ErrorAction Stop | Where-Object {[System.Char]::IsLetter( $_.DriveLetter)} | Select-Object -ExpandProperty DriveLetter | ForEach-Object{
        $part = Get-Partition -CimSession $Script:Cim -DriveLetter $_ -ErrorAction Ignore | Select-Object *
        if($null -ne $part){
            $Script:output += New-Object PSObject -Property ([ordered] @{ 
                DriveLetter = $part.DriveLetter
                PartitionNumber = $part.PartitionNumber
                OperationalStatus = $part.OperationalStatus
                'Size (MB)' = ([math]::round($part.Size/1MB, 3))
                IsSystem = $part.IsSystem
                IsBoot = $part.IsBoot
            })
        }
    }    
    
    ShowResultConvertToHtml -Result $Script:output
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}