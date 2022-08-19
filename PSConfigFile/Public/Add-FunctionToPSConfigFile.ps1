﻿
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

.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "import-module .\*.psm1 -force -verbose"

#>
Function Add-FunctionToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile')]
    PARAM(
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Function $($FunctionName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$FunctionObject = @()
        
    if ($Json.PSFunction.psobject.Properties.name -like 'Default' -and
        $Json.PSFunction.psobject.Properties.value -like 'Default') {
        $FunctionObject.Add([PSCustomObject]@{
                Name = $FunctionName 
                Command = $CommandToRun
            })
    } else {
        $Json.PSFunction | ForEach-Object {$FunctionObject.Add($_)}
        $FunctionObject.Add([PSCustomObject]@{
                Name    = $FunctionName 
                Command = $CommandToRun
            })
    }

    $Update = [psobject]@{
        Userdata    = $userdata
        PSDrive     = $Json.PSDrive
        PSFunction  = $FunctionObject
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Function added'
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function
