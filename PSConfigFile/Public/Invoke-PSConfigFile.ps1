
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

.PARAMETER DisplayOutput
Do not show the output on the console.

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
    $output = New-Item (Join-Path $env:TEMP -ChildPath "$(Get-Random).txt")
    & {
    try {
            $confile = Get-Item $ConfigFile -ErrorAction SilentlyContinue
            $logfile = Join-Path $confile.DirectoryName -ChildPath PSCustomConfigLog.log
            if ((Test-Path $logfile) -eq $false) { New-Item -Path $logfile -ItemType File -Force | Out-Null }

            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start"
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################"
            Write-Output " "
            
            $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
            if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)"
            
            # User Data
            Write-Output "  "
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:"
            $JSONParameter.Userdata.PSObject.Properties | ForEach-Object { 
                  Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] `t`t$($_.name) : $($_.value)"  
            }

            # Set Location
            if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
                Write-Output "  "
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Setting Folder Location: $($JSONParameter.SetLocation.WorkerDir)"
                Set-Location $JSONParameter.SetLocation.WorkerDir -ErrorAction SilentlyContinue
            }

            #Set Variables
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:"
            $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
                Write-Output "  "
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                New-Variable -Name $_.name -Value $_.value -Force -Scope global
            }
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFilePath : ($confile.Directory).FullName"
            New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile : $($confile.FullName)"
            New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force

            # Set PsDrives
            Write-Output "  "
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:"
            $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object { Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value.root)"
                if (-not(Get-PSDrive -Name $_.name -ErrorAction SilentlyContinue)) {
                    New-PSDrive -Name $_.name -PSProvider FileSystem -Root $_.value.root -Scope Global | Out-Null
                }
                else { Write-Warning '`nWarning: PSDrive - Already exists'}
            }

            # Set Alias
           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: "
            $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $tmp = $null
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                $command = "function global:$($_.name) {$($_.value)}"
                $tmp = [scriptblock]::Create($command)
                $tmp.invoke() | Tee-Object -FilePath $logfile -Append
            }

            # Execute Commands
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: "
            $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $tmp = $null
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] ScriptBlock Output:"
                $tmp = [scriptblock]::Create($_.value)
                $tmp.invoke() | Tee-Object -FilePath $logfile -Append
            }

           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################"
           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End"
    }
    catch {
        Write-Error "An Error...:`n $_.Exception `n $_.Exception.message"
    }
    } *> $output.FullName

    $Feedback = Get-Content $output.FullName
    $warning = Select-String -Path $output.FullName -Pattern 'Warning'
    $configErrors = Select-String -Path $output.FullName -Pattern 'Error'

    if ($DisplayOutput){ $Feedback}
    else {Write-Output "Invoke-PSConfigFile Completed: $($warning.count) Warnings; $($configErrors.count) Errors"}

    

} #end Function
