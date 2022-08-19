<#PSScriptInfo

.VERSION 1.1.4

.GUID b282e3bd-08f5-41ba-9c63-8306ce5c45a6

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

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

#Requires -Module PSWriteColor


<#

.DESCRIPTION
Read and execute the config file

#>


<#
.SYNOPSIS
Executes the config from the json file.

.DESCRIPTION
Executes the config from the json file.

.PARAMETER ConfigFile
Path to the the config file that was created by New-PSConfigFile

.PARAMETER DisplayOutput
By default no output is displayed, switch this on to display the output. Or use Show-PSConfigFile to display the last execution.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSCustomConfig.json

#>
Function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

    #region import file
    try {
        $confile = Get-Item $ConfigFile -ErrorAction Stop
        $Script:PSConfigFileOutput = [System.Collections.Generic.List[string]]::new()
        $PSConfigFileOutput.Add('')

        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
        $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
        if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
        $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)")
    } catch {Write-Warning "Error Import: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Import: Message:$($_.Exception.Message)") }
    #endregion

    #region User Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:")
        $JSONParameter.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region User Data Modified
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Config File Modified Data:")
        $JSONParameter.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Variables
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:")
        $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            try {
                New-Variable -Name $_.name -Value $_.value -Force -Scope global -ErrorAction Stop
            } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
        }
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
        $PSConfigFileOutput.Add($output)
        New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force -ErrorAction Stop
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
        $PSConfigFileOutput.Add($output)
        New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force -ErrorAction Stop
    } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}

    #endregion

    #region Set PsDrives
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
        $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value.root)
            $PSConfigFileOutput.Add($output)
            if (-not(Get-PSDrive -Name $_.name -ErrorAction SilentlyContinue)) {
                New-PSDrive -Name $_.name -PSProvider FileSystem -Root $_.value.root -Scope Global | Out-Null
            } else { Write-Warning 'Warning: PSDrive - Already exists'; $PSConfigFileOutput.Add('<w>Warning: PSDrive - Already exists') }
        }
    } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Function
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Functions: ")
        $JSONParameter.PSFunction.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            $command = "function global:$($_.name) {$($_.value)}"
            $tmp = [scriptblock]::Create($command)
            $tmp.invoke()
        }
    } catch {Write-Warning "Error Function: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Function: Message:$($_.Exception.Message)")}
    #endregion

    #region Creds
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
        if (-not([string]::IsNullOrEmpty($JSONParameter.PSCreds[0]))) {
            foreach ($Cred in ($JSONParameter.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"})) {
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
    #endregion

    #region Set PSDefaults
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting PSDefaults:")
        foreach ($PSD in  ($JSONParameter.PSDefaults | Where-Object {$_ -notlike $null})) {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($PSD.Name.Split(':')[0]), $($PSD.Name.Split(':')[1]), $($PSD.Value)
            $PSConfigFileOutput.Add($output)
            $PSDefaultParameterValues.Remove($PSD.Name)
            $PSDefaultParameterValues.Add($PSD.Name, $PSD.Value)
        }
    } catch {Write-Warning "Error PSDefaults $($PSD.Name): `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDefaults $($PSD.Name): Message:$($_.Exception.Message)")}
    #endregion

    #region Set Location
    try {
        if ($null -notlike $JSONParameter.SetLocation) {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($JSONParameter.SetLocation.WorkerDir))
            $PSConfigFileOutput.Add($output)
            if ([bool](Get-PSDrive $($JSONParameter.SetLocation.WorkerDir) -ErrorAction SilentlyContinue)) { Set-Location -Path "$($JSONParameter.SetLocation.WorkerDir):" }
            elseif (Test-Path $($JSONParameter.SetLocation.WorkerDir)) { Set-Location $($JSONParameter.SetLocation.WorkerDir) }
            else { Write-Error '<e>No valid location found.' }
        }
    } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
    #endregion

    #region Execute Commands
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: ")
        $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())]  ScriptBlock Output:")
            $tmp = [scriptblock]::Create($_.value)
            $tmp.invoke()
            #$tmp.invoke() 
            Invoke-Command $tmp -OutVariable output
            $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] $($output | Out-String)")
        }
    } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
    #endregion

    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
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