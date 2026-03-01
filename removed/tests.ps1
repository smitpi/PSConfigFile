



New-PSConfigFile -ConfigDir C:\temp\tmp -BackupsToKeep 2
# Fix: 
#[Created] C:\Temp\tmp\PSConfigFile.xml                                                              
#WARNING: Error Credentials:                                                                                 
#Message:The property 'Edition' cannot be found on this object. Verify that the property exists.

##TODO Check for duplicate config before saving.
##TODO Added script line errors on invoke

Add-CommandToPSConfigFile -ScriptBlockName 2 -ScriptBlock "get-childitem c:\temp"

$cred = Get-Credential
Add-CredentialToPSConfigFile -Name Cred -Credential $cred
Invoke-PSConfigFile -ConfigFile $psconfigfile -DisplayOutput

Add-FunctionToPSConfigFile -FunctionName cdt -CommandToRun "cd \temp"
Invoke-PSConfigFile -ConfigFile $psconfigfile -DisplayOutput

New-PSDrive -Name tmp -PSProvider FileSystem -Root C:\temp\tmp
Add-LocationToPSConfigFile -LocationType Folder -Path C:\temp\tmp
Add-LocationToPSConfigFile -LocationType PSDrive -Path tmp
Add-PSDriveToPSConfigFile -DriveName tmp
Invoke-PSConfigFile -ConfigFile $psconfigfile -DisplayOutput

Add-PSDefaultParameterToPSConfigFile -Function Start-PSSysTray -Parameter PSSysTrayConfigFile -Value "C:\Users\ladmin\Dropbox\#Profile\Documents\PowerShell\ProdModules\@Lab-Scripts\LabScripts\Private\App_Setup\PSLauncher\PSSysTrayConfig.csv"
Invoke-PSConfigFile -ConfigFile $psconfigfile -DisplayOutput

[int]$blah = 1
[string]$blah2 = "11"
$object = [pscustomobject]@{
    Name = "Name"
    Blah = $blah
    Blah2 = $blah2
}
Add-VariableToPSConfigFile -VariableNames blah
Add-VariableToPSConfigFile -VariableNames blah2
Add-VariableToPSConfigFile -VariableNames object

Remove-Variable blah,blah2,object
Invoke-PSConfigFile -ConfigFile $psconfigfile -DisplayOutput


Export-PSConfigFilePFX -Path c:\temp\tmp -Credential $cred
Import-PSConfigFilePFX -Path C:\temp\tmp\PSConfigFileCert.pfx -Credential $cred -Force

Update-PSConfigFileCredentials -RenewSavedPasswords All
New-PSConfigCertificate

Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
notepad $profile



###################################

Set-PSConfigFileExecution -PSProfile RemoveScript -DisplayOutput
notepad $profile

Remove-ConfigFromPSConfigFile -Config Command -Value Hello
Remove-ConfigFromPSConfigFile -Config Command -Value 2
Remove-ConfigFromPSConfigFile -Config Credential -Value Cred
Remove-ConfigFromPSConfigFile -Config Function -Value cdt


Remove-ConfigFromPSConfigFile -Config PSDrive -Value tmp
Remove-ConfigFromPSConfigFile -Config Variable -Value object


Remove-ConfigFromPSConfigFile -Config Location
#Error Creds: Message:The property 'WorkerDir' cannot be found on this object. Verify that the property exists.


Remove-ConfigFromPSConfigFile -Config PSDefaults -Value Start-PSSysTray
# Did not delete

Remove-ConfigFromPSConfigFile -Config Variable -Value blah
Remove-ConfigFromPSConfigFile -Config Variable -Value blah2
#Removes both variables.


<#
WARNING: Error Credentials:                                                                                 
Message:The property 'Edition' cannot be found on this object. Verify that the property exists.                                                                                                 
WARNING: Error Location:                                                                                    
Message:The property 'WorkerDir' cannot be found on this object. Verify that the property exists.                                                                                               
[09:40:41] PSConfigFile Execution Start                                                             
[09:40:41] ##############################################################                           
[09:40:41] Module Version              : 0.1.36                                                     
[09:40:41] Using PSCustomConfig File   : C:\Temp\tmp\PSConfigFile.xml                                                                                                                                   
[09:40:41] ################### Config File: Meta Data ###################                           
[09:40:41] Creation Data:                                                                           
[09:40:41]              Owner                       : ladmin                                        
[09:40:41]              CreatedOn                   : 2026-03-01 09:04:34Z                          
[09:40:41]              PSExecutionPolicy           :                                               
[09:40:41]              Path                        : C:\Temp\tmp\PSConfigFile.xml                  
[09:40:41]              Hostname                    : desktop-v0ijhne                               
[09:40:41]              PSEdition                   : Core (ver 7.4.13)                             
[09:40:41]              OS                          : Microsoft Windows 11 Pro                      
[09:40:41]              BackupsToKeep               : 2                                             
[09:40:41]              Backups Removed             : 2                                                                                                                                                 
[09:40:41] Modification Data:                                                                       
[09:40:41]              ModifiedDate                : 3/1/2026 9:39:57 AM                           
[09:40:41]              ModifiedAction              : Removed Config: Variable:                                                                                                                         
[09:40:41] ###################### Session Details: ######################                           
[09:40:41] Current Session:                                                                         
[09:40:41]              User                        : ladmin                                        
[09:40:41]              PSExecutionPolicy           :                                               
[09:40:41]              Hostname                    : desktop-v0ijhne                               
[09:40:41]              PSEdition                   : Core (ver 7.4.13)                             
[09:40:41]              OS                          : Microsoft Windows 11 Pro                                                                                                                          
[09:40:43] #################### Config File Details: ####################                           
[09:40:43] Setting Variables:                                                                       
[09:40:43]  PSConfigFilePath            : C:\Temp\tmp                                               
[09:40:43]  PSConfigFile                : C:\Temp\tmp\PSConfigFile.xml                                                                                                                                  
[09:40:43] Creating PSDrives:                                                                                                                                                                           
[09:40:43] Creating Functions:                                                                                                                                                                          
[09:40:43] Creating Credentials:                                                                                                                                                                        
[09:40:43] Setting PSDefaultParameterValues:                                                        
[09:40:43]  Function:Start-PSSysTray      Parameter:PSSysTrayConfigFile           : C:\Users\ladmin\Dropbox\#Profile\Documents\PowerShell\ProdModules\@Lab-Scripts\LabScripts\Private\App_Setup\PSLauncher\PSSysTrayConfig.csv                                                                                                                                                                                  
[09:40:43] Setting Working Directory:                                                               
Error Creds: Message:The property 'WorkerDir' cannot be found on this object. Verify that the property exists.                                                                                                                                                                                              
[09:40:43] Executing Commands:                                                                                                                                                                          
[09:40:43] ##############################################################                           
[09:40:43] PSConfigFile Execution End 

#>