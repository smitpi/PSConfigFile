
<#PSScriptInfo

.VERSION 1.1.5

.GUID 0fcfdc24-96af-490f-a636-3a8a6bfb4ece

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [14/10/2021_13:56] Initial Script Creating
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#> 







<#

.DESCRIPTION
Add PSDrive to the config file

#>


<#
.SYNOPSIS
Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.

.DESCRIPTION
Use this function to register a PowerShell drive (PSDrive) in your configuration file. When the config is invoked, the drive will be automatically available in your session, streamlining access to file systems, registries, or other providers. The PSDrive must already exist (use New-PSDrive to create it first).

.PARAMETER DriveName
The name of the PSDrive to add. The drive must already exist in the current session.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
New-PSDrive -Name TempDir -PSProvider FileSystem -Root "C:\\Temp"
Add-PSDriveToPSConfigFile -DriveName TempDir
Registers the 'TempDir' PSDrive in the config file for automatic use in future sessions.

.EXAMPLE
Add-PSDriveToPSConfigFile -DriveName ProdModules -Force
Adds the 'ProdModules' PSDrive, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to ensure custom drives are always available in your PowerShell environment.
#>
function Add-PSDriveToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile')]
    param(
        [ValidateScript({ if (Get-PSDrive $_) { $true } else { $false } })]
        [string]$DriveName,
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
            ModifiedAction = "Added PSDrive: $($DriveName)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$PSDriveObject = @()
    $InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name, Root
    if ($null -eq $InputDrive) { Write-Error 'Unknown psdrive'; break }

    if ([string]::IsNullOrEmpty($XMLData.PSDrive)) {
        $PSDriveObject.Add([PSCustomObject]@{
                Name = $InputDrive.Name
                Root = $InputDrive.Root
            })
    } else {
        $XMLData.PSDrive | Where-Object {$_.Name -notlike $InputDrive.Name} | ForEach-Object {$PSDriveObject.Add($_)}
        $PSDriveObject.Add([PSCustomObject]@{
                Name = $InputDrive.Name
                Root = $InputDrive.Root
            })
    }

    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = ($PSDriveObject | Where-Object {$_ -notlike $null})
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = $XMLData.Execute
    }
    try {
        Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm).xml" -Force
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'PSDrive Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($DriveName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function


