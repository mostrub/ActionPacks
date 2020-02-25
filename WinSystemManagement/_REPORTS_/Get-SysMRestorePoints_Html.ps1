#Requires -Version 4.0

<#
.SYNOPSIS
     Generates a report with the restore points on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_REPORTS_ 

.Parameter RestorePointID
    Specifies the restore point number, the value 0 returns all restore points

.Parameter LastStatus
    Gets the status of the most recent system restore operation

.Parameter Properties
    List of properties to expand, comma separated e.g. SequenceNumber,Description. Use * for all properties
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [string[]]$Properties = @('Description','CreationTime','EventType','RestorePointType')
    $Script:output

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        $Script:output = Get-ComputerRestorePoint @cmdArgs | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){            
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {            
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
    }      
    
    ShowResultConvertToHtml -Result $Script:output
}
catch{
    throw
}
finally{
}