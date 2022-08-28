
<#PSScriptInfo

.VERSION 1.1.4

.GUID 98459c57-e214-4a9f-b523-efa2329a0340

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
Created [04/10/2021_19:05] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:31] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#>









<#

.DESCRIPTION
Add a command to the config file

#>


<#
.SYNOPSIS
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.PARAMETER ScriptBlockName
Name for the script block

.PARAMETER ScriptBlock
The commands to be executed

.PARAMETER Force
Will delete the config file before saving the new one. If false, then the config file will be renamed.


.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\"

#>
Function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    PARAM(
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
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Command $($ScriptBlockName)"
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
        Write-Host 'Command Added' -ForegroundColor Green
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }



} #end Function
