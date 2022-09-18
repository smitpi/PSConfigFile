
<#PSScriptInfo

.VERSION 0.1.2

.GUID c3886845-ff95-4e7c-9284-5b297fcb102a

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
Created [13/11/2021_15:18] Initial Script Creating
Updated [13/11/2021_16:30] Added Function Script
Updated [18/11/2021_08:31] Changed the update script to Set-PSConfigFileExecution

#>





<#

.DESCRIPTION
Add Function to the config file.

#>


<#
.SYNOPSIS
Creates Shortcuts (Functions) to commands or script blocks

.DESCRIPTION
Creates Shortcuts (Functions) to commands or script blocks

.PARAMETER FunctionName
Name to use for the command

.PARAMETER CommandToRun
Command to run in a string format

.PARAMETER Force
Will delete the config file before saving the new one. If false, then the config file will be renamed.


.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "import-module .\*.psm1 -force -verbose"

#>
Function Add-FunctionToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile')]
    PARAM(
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
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Added Function: $($FunctionName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
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
        $XMLData.PSFunction | ForEach-Object {$FunctionObject.Add($_)}
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
