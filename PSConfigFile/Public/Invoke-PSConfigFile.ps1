<#PSScriptInfo

.VERSION 1.1.4

.GUID b282e3bd-08f5-41ba-9c63-8306ce5c45a6

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS powershell ps

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
Updated [13/11/2021_16:30] Added Alias Script

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
Invoke-PSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json

#>
Function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

    try {
        #region import file
        $confile = Get-Item $ConfigFile -ErrorAction Stop
        $Script:PSConfigFileOutput = [System.Collections.Generic.List[string]]::new()
        $PSConfigFileOutput.Add('')

        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
        $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
        if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
        $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)")
        #endregion
        #region User Data
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:")
        $JSONParameter.Userdata.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
        #endregion

        #region Set Variables
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:")
            $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $PSConfigFileOutput.Add($output)
                #$PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) `t`t`t`t: $($_.value)"
                New-Variable -Name $_.name -Value $_.value -Force -Scope global
            }
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}

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
                } else { Write-Warning '<w>Warning: PSDrive - Already exists' }
            }
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}
        #endregion

        #region Set Alias
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: ")
            $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $tmp = $null
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $PSConfigFileOutput.Add($output)
                $command = "function global:$($_.name) {$($_.value)}"
                $tmp = [scriptblock]::Create($command)
                $tmp.invoke()
            }
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}
        #endregion

        #region Creds
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
            $selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction Stop
            if ($selfcert.NotAfter -lt (Get-Date)) {Write-Error 'Certificate Expired'}
            else {
                $index = 1
                $JSONParameter.PSCreds.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $("PSConfigFileCreds$($index)"), $($_.name)
                    $PSConfigFileOutput.Add($output)
                    $EncryptedBytes = [System.Convert]::FromBase64String($_.value)
                    if ($PSVersionTable.PSEdition -like "Desktop") {
                        $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, $true)}
                    else {
                        $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)}
                    $DecryptedPwd = [system.text.encoding]::UTF8.GetString($DecryptedBytes) | ConvertTo-SecureString -AsPlainText -Force
                    New-Variable -Name $"PSConfigFileCreds$($index)" -Value (New-Object System.Management.Automation.PSCredential ($_.name, $DecryptedPwd)) -Scope Global
                    $index++
                }
            }
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}
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
            }
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}
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
        } catch {Write-Warning "<e>Error: `n`tMessage:$($_.Exception.Message)"}
        #endregion

        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End")
    } catch {
        Write-Error "<e>An Error...:`n $_"
    }

    if ($DisplayOutput) {
        foreach ($line in $PSConfigFileOutput) {
            if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
            if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
            if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
            if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
        }
    } else {
        Write-Output '[PSConfigFile] Output:'
        Write-Output "[$ConfigFile] Invoke-PSConfigFile Completed:"
    }
} #end Function