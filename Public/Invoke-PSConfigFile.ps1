
<#PSScriptInfo

.VERSION 1.1.4

.GUID b282e3bd-08f5-41ba-9c63-8306ce5c45a6

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

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
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json

#>
Function Invoke-PSConfigFile {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile
    )
    try {
        $confile = Get-Item $ConfigFile -ErrorAction SilentlyContinue
        $logfile = Join-Path $confile.DirectoryName -ChildPath PSCustomConfigLog.log
        if ((Test-Path $logfile) -eq $false) { New-Item -Path $logfile -ItemType File -Force | Out-Null }

        Write-Color 'PSConfigFile Execution Start' -ShowTime -Color DarkCyan -LinesBefore 4 -LogFile $logfile
        Write-Color '#######################################################' -ShowTime -Color Green -LogFile $logfile

        $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json | Tee-Object -FilePath $logfile -Append
        if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
        Write-Color 'Using PSCustomConfig file: ', $($confile.fullname) -ShowTime -Color DarkCyan, DarkYellow -LogFile $logfile

        # User Data
        Write-Color 'Details of Config File:' -ShowTime -Color DarkCyan -LinesBefore 1 
        $JSONParameter.Userdata.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -StartTab 4 }

        # Set Location
        if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
            Write-Color 'Setting Folder Location: ', $($JSONParameter.SetLocation.WorkerDir) -ShowTime -Color DarkCyan, DarkYellow -LinesBefore 1 -LogFile $logfile
            Set-Location $JSONParameter.SetLocation.WorkerDir -ErrorAction SilentlyContinue
        }

        #Set Variables
        Write-Color 'Setting Default Variables:' -ShowTime -Color DarkCyan -LinesBefore 1 -LogFile $logfile
        $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object { 
            Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile 
            New-Variable -Name $_.name -Value $_.value -Force -Scope global 
        }
        Write-Color 'PSConfigFilePath', ':', ($confile.Directory).FullName -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile
        New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force
        Write-Color 'PSConfigFile', ':', $confile.FullName -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile 
        New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force

        # Set PsDrives
        Write-Color 'Creating PSDrives:' -ShowTime -Color DarkCyan -LinesBefore 1 -LogFile $logfile
        $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value.root -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile -NoNewLine
            if (-not(Get-PSDrive -Name $_.name -ErrorAction SilentlyContinue)) {
                New-PSDrive -Name $_.name -PSProvider FileSystem -Root $_.value.root -Scope Global | Out-Null
                Write-Color ' - Mapped' -Color Yellow -LogFile $logfile
            }
            else { Write-Color ' - Already exists' -Color Yellow -LogFile $logfile }
        }

        # Set Alias
        Write-Color 'Creating Custom Aliases: ' -ShowTime -Color DarkCyan -LinesBefore 1 -LogFile $logfile
        $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile
            $command = "function global:$($_.name) {$($_.value)}"
            $tmp = [scriptblock]::Create($command)
            $tmp.invoke() | Tee-Object -FilePath $logfile -Append
        }

        # Execute Commands
        Write-Color 'Executing Custom Commands: ' -ShowTime -Color DarkCyan -LinesBefore 1 -LogFile $logfile
        $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -LogFile $logfile -LinesBefore 1
            Write-Color 'ScriptBlock Output:' -Color Yellow -ShowTime -LogFile $logfile
            $tmp = [scriptblock]::Create($_.value)
            $tmp.invoke() | Tee-Object -FilePath $logfile -Append
        }

        Write-Color '#######################################################' -ShowTime -Color Green -LinesBefore 1 -LogFile $logfile
        Write-Color 'PSConfigFile Execution End' -ShowTime -Color DarkCyan -LogFile $logfile
    }
    catch {
        Write-Output 'An Error...' | Tee-Object -FilePath $logfile -Append
        $_.Exception | Tee-Object -FilePath $logfile -Append
        $_.Exception.message | Tee-Object -FilePath $logfile -Append
    }
} #end Function
