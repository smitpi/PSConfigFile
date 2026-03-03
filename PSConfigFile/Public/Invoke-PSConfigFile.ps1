<#PSScriptInfo

.VERSION 1.1.5

.GUID b282e3bd-08f5-41ba-9c63-8306ce5c45a6

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS PowerShell ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/09/2021_08:15] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#> 





<#

.DESCRIPTION
Read and execute the config file

#>


<#
.SYNOPSIS
Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.

.DESCRIPTION
Use this function to load a PSConfigFile XML configuration file and apply all stored settings to your current session. This includes setting variables, creating PSDrives, defining functions, importing credentials, applying default parameters, setting the working directory, and executing startup commands. Use this to quickly restore your preferred environment or automate session setup across systems.

.PARAMETER ConfigFile
The path to the configuration XML file created by New-PSConfigFile. Must have a .xml extension.

.PARAMETER DisplayOutput
If specified, displays detailed output of each configuration step. Otherwise, only completion status is shown. Use Show-PSConfigFile to display the last execution output.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSConfigFile.xml
Loads and applies all settings from the specified config file.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile .\PSConfigFile.xml -DisplayOutput
Runs the config file and displays detailed output for each step.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to automate and standardize your PowerShell environment setup.
#>
function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.xml') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

    try {
        $confile = Get-Item $ConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            exit
        }
    }
    #region import file
    try {
        $confile = Get-Item $ConfigFile -ErrorAction Stop
        $XMLData = Import-Clixml -Path $confile.FullName
        if ([string]::IsNullOrEmpty($XMLData.Userdata)) { Write-Error 'Valid Parameters file not found'; break }
    } catch {Write-Warning "Error Import: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Import: Message:$($_.Exception.Message)") }

    try {
        $Script:PSConfigFileOutput = [System.Collections.Generic.List[string]]::new()
        $PSConfigFileOutput.Add('')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Module Version', "$((Get-Module PSConfigFile -ListAvailable | Sort-Object -Property Version -Descending)[0].Version)"
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Using PSCustomConfig File', "$($confile.fullname)"
        $PSConfigFileOutput.Add($output)
    } catch {Write-Warning "Error Config Start: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Config Start: Message:$($_.Exception.Message)") }
    #endregion

    #region User Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ################### Config File: Meta Data ###################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creation Data:")
        $XMLData.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
        $BackupsToDelete = Get-ChildItem "$($confile.Directory)\Outdated_PSConfigFile*" | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $($XMLData.Userdata.BackupsToKeep)
        if ($null -ne $BackupsToDelete) {
            $BackupsToDelete | Remove-Item -Force -ErrorAction Stop
            #$output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'Backups Removed', $($BackupsToDelete.count)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region User Data Modified
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Modification Data:")
        $XMLData.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
    #endregion

    #region Session Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ###################### Session Details: ######################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Current Session:")
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'User', "$($env:USERNAME.ToLower())" 
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'PSExecutionPolicy', $env:PSExecutionPolicyPreference
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'Hostname', (([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName).ToLower()
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'PSEdition', "$($PSVersionTable.PSEdition) (ver $($PSVersionTable.PSVersion.ToString()))"
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'OS', (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $PSConfigFileOutput.Add($output)
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Variables
    if (-not [string]::IsNullOrEmpty($XMLData.SetVariable)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #################### Config File Details: ####################")
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Variables:")
            foreach ($SetVariable in  ($XMLData.SetVariable | Where-Object {$_ -notlike $null})) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetVariable.name), $($SetVariable.value)
                $PSConfigFileOutput.Add($output)
                try {
                    New-Variable -Name $($SetVariable.name) -Value $($SetVariable.value) -Force -Scope global -ErrorAction Stop
                } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
            }
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force -ErrorAction Stop
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force -ErrorAction Stop
        } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Set PsDrives
    if (-not [string]::IsNullOrEmpty($XMLData.PSDrive)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
            foreach ($SetPSDrive in  ($XMLData.PSDrive | Where-Object {$_ -notlike $null})) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSDrive.Name), $($SetPSDrive.root)
                $PSConfigFileOutput.Add($output)
                if (-not(Get-PSDrive -Name $SetPSDrive.name -ErrorAction SilentlyContinue)) {
                    New-PSDrive -Name $SetPSDrive.name -PSProvider FileSystem -Root $SetPSDrive.root -Scope Global | Out-Null
                } else {$PSConfigFileOutput.Add('<w>Warning: PSDrive - Already exists') }
            }
        } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Set Function
    if (-not [string]::IsNullOrEmpty($XMLData.PSFunction)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Functions: ")
            foreach ($SetPSFunction in  ($XMLData.PSFunction | Where-Object {$_ -notlike $null})) {
                $tmp = $null
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSFunction.name), $($SetPSFunction.Command)
                $PSConfigFileOutput.Add($output)
                $command = "function global:$($SetPSFunction.name) {$($SetPSFunction.command)}"
                $tmp = [scriptblock]::Create($command)
                $tmp.invoke()
            }
        } catch {Write-Warning "Error Function: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Function: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Creds
    if (-not [string]::IsNullOrEmpty($XMLData.PSCreds)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
            if (($XMLData.PSCreds.edition -contains 'PSDesktop') -and $PSVersionTable.edition -eq 'PSDesktop') {
                Write-Error ' PSConfigFile Credentials is only a PSCore feature'; $PSConfigFileOutput.Add('<e>Error Credentials: Message: PSConfigFile Credentials is only a PSCore feature')
            }
            foreach ($Cred in ($XMLData.PSCreds | Where-Object {$_.Edition -like 'PSCore'})) {
                if ($null -ne $Cred) {
                    $selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction Stop
                    if ($selfcert.NotAfter -lt (Get-Date)) {
                        Write-Error "User Certificate not found.`nOr has expired"; $PSConfigFileOutput.Add('<e>Error Credentials: Message: User Certificate not found. Or has expired')
                    } else {
                        $credname = $Cred.Name
                        $username = $Cred.UserName
                        $password = $Cred.EncryptedPwd
                        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($credname), "(PS$($PSVersionTable.PSEdition)) $($username)"
                        $PSConfigFileOutput.Add($output)
                        $EncryptedBytes = [System.Convert]::FromBase64String($password)
                        if ($PSVersionTable.PSEdition -like 'Desktop') {
                            try {
                                $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, $true)
                            } catch {Write-Warning "Error Credentials: `n`tMessage: Password was encoded in PowerShell Core"; $PSConfigFileOutput.Add('<e>Error Credentials: Message: Password was encoded in PowerShell Core')}
                        } else {
                            try {
                                $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
                            } catch {Write-Warning "Error Credentials: `n`tMessage: Password was encoded in PowerShell Desktop"; $PSConfigFileOutput.Add('<e>Error Credentials: Message:  Password was encoded in PowerShell Desktop')}
                        }
                        try {
                            $DecryptedPwd = [system.text.encoding]::UTF8.GetString($DecryptedBytes) | ConvertTo-SecureString -AsPlainText -Force
                            New-Variable -Name $Credname -Value (New-Object System.Management.Automation.PSCredential ($username, $DecryptedPwd)) -Scope Global -Force -ErrorAction Stop
                        } catch {Write-Warning "Error Credentials: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Credentials: Message:$($_.Exception.Message)")}
                    }
                }
            }
        } catch {Write-Warning "Error Credentials: `n`tMessage:$($_.Exception.Message)"}
    }
    #endregion

    #region Set PSDefaults
    if (-not [string]::IsNullOrEmpty($XMLData.PSDefaults)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting PSDefaultParameterValues:")
            $SortDefaults = ($XMLData.PSDefaults | Where-Object {$_ -notlike $null}) | Sort-Object -Property Name
            foreach ($PSD in $SortDefaults) {
                if ($global:PSDefaultParameterValues["$($PSD.Name)"]) {$global:PSDefaultParameterValues["$($PSD.Name)"] = $PSD.Value}
                else {$global:PSDefaultParameterValues.Add("$($PSD.Name)", "$($PSD.Value)")}
            }
            foreach ($Defaults in ($global:PSDefaultParameterValues.GetEnumerator() | Sort-Object -Property Name)) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($Defaults.Name.Split(':')[0]), $($Defaults.Name.Split(':')[1]), $($Defaults.Value)
                $PSConfigFileOutput.Add($output)
            }
        } catch {Write-Warning "Error PSDefaults $($PSD.Name): `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDefaults $($PSD.Name): Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Set Location
    if (-not [string]::IsNullOrEmpty($XMLData.SetLocation)) {
        try {
            $SetPath = $XMLData.SetLocation[0]
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($SetPath.value))
            $PSConfigFileOutput.Add($output)
            if ($SetPath.type -eq 'PSDrive') {
                Set-Location "$($SetPath.Name):"
                else { Set-Location $($SetPath.value)}
            }
        } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Execute Commands
    if (-not [string]::IsNullOrEmpty($XMLData.execute)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Commands: ")
            foreach ($execute in  ($XMLData.execute | Where-Object {$_ -notlike $null})) {
                $tmp = $null
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($execute.name), $($execute.ScriptBlock)
                $PSConfigFileOutput.Add($output)
                $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())]  ScriptBlock Output:")
                $tmp = [scriptblock]::Create($execute.ScriptBlock)
                Invoke-Command $tmp -OutVariable output
                $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] $($output | Out-String)")
            }
        } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
    }
    #endregion


    $PSConfigFileOutput.Add('<h>  ')
    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End")

    if ($DisplayOutput) {
        foreach ($line in $PSConfigFileOutput) {
            if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
            if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
            if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
            if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
        }
    } else {
        Write-Host '[Completed]' -NoNewline -ForegroundColor Yellow; Write-Host ' Invoke-PSConfigFile ' -ForegroundColor Cyan
        Write-Host '[ConfigFile]: ' -ForegroundColor Yellow -NoNewline; Write-Host "$ConfigFile" -ForegroundColor DarkRed
    }
    
} #end Function

