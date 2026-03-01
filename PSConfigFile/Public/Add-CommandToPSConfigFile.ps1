
<#PSScriptInfo

.VERSION 1.1.4

.GUID 98459c57-e214-4a9f-b523-efa2329a0340

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
Created [04/10/2021_19:05] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:31] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#>









<#
.SYNOPSIS
Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.

.DESCRIPTION
Use this function to store custom commands or script blocks in your configuration file. These commands will be executed every time the config file is invoked using Invoke-PSConfigFile. This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

.PARAMETER ScriptBlockName
The unique name to assign to the script block. This name is used to identify and manage the command within the config file.

.PARAMETER ScriptBlock
The PowerShell command(s) or script block to be executed. Provide as a string. Example: "Get-ChildItem C:\\Logs | Out-File C:\\log.txt"

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\\"
Adds a script block named 'DriveC' that lists the contents of the C drive every time the config is invoked.

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName Startup -ScriptBlock "Write-Host 'Welcome!'" -Force
Adds a script block named 'Startup' that displays a welcome message, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.
#>
function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock,
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
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Added Command: $($ScriptBlockName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$ExecuteObject = @()
    
    if ([string]::IsNullOrEmpty($XMLData.Execute)) {
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = 0
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    } else {
        $XMLData.Execute | ForEach-Object {$ExecuteObject.Add($_)}
        $IndexID = $ExecuteObject.IndexID | Sort-Object -Descending | Select-Object -First 1
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = ($IndexID + 1 )
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    }
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = ($ExecuteObject | Where-Object {$_ -notlike $null})
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
        Write-Host 'Command Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($ScriptBlockName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function
