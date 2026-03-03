
<#PSScriptInfo

.VERSION 1.1.5

.GUID c3886845-ff95-4e7c-9284-5b297fcb102a

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
Created [13/11/2021_15:18] Initial Script Creating
Updated [13/11/2021_16:30] Added Function Script
Updated [18/11/2021_08:31] Changed the update script to Set-PSConfigFileExecution

.PRIVATEDATA

#> 







<#

.DESCRIPTION
Add Function to the config file.

#>



<#
.SYNOPSIS
Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.

.DESCRIPTION
Use this function to define named PowerShell functions (shortcuts) that execute specific commands or script blocks. These functions are stored in your configuration file and can be invoked automatically or manually, streamlining repetitive tasks and environment setup. This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

.PARAMETER FunctionName
The unique name to assign to the custom function. This name is used to identify and manage the function within the config file.

.PARAMETER CommandToRun
The PowerShell command(s) or script block to be executed by the function. Provide as a string. Example: "Import-Module .\*.psm1 -Force -Verbose"

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "Import-Module .\*.psm1 -Force -Verbose"
Adds a function named 'psml' that imports all PowerShell modules in the current directory with force and verbose options.

.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName CleanLogs -CommandToRun "Remove-Item C:\\Logs\\* -Recurse -Force" -Force
Adds a function named 'CleanLogs' to delete all log files, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.
#>
function Add-FunctionToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun,
        [switch]$Force
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $XMLData = Import-Clixml -Path $confile.FullName
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Added Function: $($FunctionName)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$FunctionObject = @()
        
    if ([string]::IsNullOrEmpty($XMLData.PSFunction)) {
        $FunctionObject.Add([PSCustomObject]@{
                Name    = $FunctionName 
                Command = $CommandToRun
            })
    } else {
        $XMLData.PSFunction | Where-Object {$_.Name -notlike $FunctionName} | ForEach-Object {$FunctionObject.Add($_)}
        $FunctionObject.Add([PSCustomObject]@{
                Name    = $FunctionName 
                Command = $CommandToRun
            })
    }

    $Update = [psobject]@{
        Userdata    = $userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = ($FunctionObject | Where-Object {$_ -notlike $null})
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = $XMLData.Execute
    }
    try {
        if ($force) {
            Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
            Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
        } else {
            Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
            Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
        }
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'Function Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($FunctionName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function

