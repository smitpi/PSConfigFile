
<#PSScriptInfo

.VERSION 1.1.5

.GUID 9f023856-311a-4463-a042-f57955ced2de

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS powershell ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [04/10/2021_19:06] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#> 



<#

.DESCRIPTION
Add a start-up location to the config file

#>



<#
.SYNOPSIS
Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

.DESCRIPTION
Specifies a default working location for your PowerShell session, either as a folder path or a PSDrive. When the config file is invoked using Invoke-PSConfigFile, your session will automatically change to this location. This streamlines your workflow and ensures you always start in the correct directory or drive.

.PARAMETER PSDriveName
The name of the PowerShell drive to set as the default location. Must be a valid PSDrive. Use this parameter if you want to set a PSDrive as the start-up location.

.PARAMETER FolderPath
The path to the folder to set as the default location. Must be a valid directory. Use this parameter if you want to set a filesystem folder as the start-up location.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-LocationToPSConfigFile -PSDriveName temp
Sets the default location to the 'temp' PSDrive when the config is invoked.

.EXAMPLE
Add-LocationToPSConfigFile -FolderPath C:\temp
Sets the default location to the 'C:\temp' folder when the config is invoked.

#>

function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    param(
        [ValidateScript( {( [bool](Get-PSDrive $_)) })]
        [string]$PSDriveName,
        [ValidateScript( { ( Test-Path $_) })]
        [System.IO.DirectoryInfo]$FolderPath,
        [switch]$Force
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }
    if ((-not($PSBoundParameters.ContainsKey('PSDriveName'))) -and (-not($PSBoundParameters.ContainsKey('FolderPath')))) {
        Write-Error 'Parameters are emty'
    }
    if ($PSBoundParameters.ContainsKey('PSDriveName')) {
        try {
            $Drive = Get-PSDrive $PSDriveName -ErrorAction Stop
            $PathName = $Drive.Name
            $PathValue = $Drive.Root
            $PathType = 'PSDrive'
        } catch {
            Write-Error "PSDrive: Error: `n $_"
        }
    }
    if ($PSBoundParameters.ContainsKey('FolderPath')) {
        try {
            $PathName = $FolderPath.Name
            $PathValue = $FolderPath.FullName
            $PathType = 'Folder'
        } catch {
            Write-Error "Folder: Error: `n $_"
        }

    }
    $Update = @()
    [System.Collections.generic.List[PSObject]]$SetLocation = @()
    $SetLocation.Add([PSCustomObject]@{
            Name  = $PathName
            value = $PathValue
            Type  = $PathType
        })

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
            ModifiedAction = "Working Directory Changed: $($PathName)"
        }
    }


    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $SetLocation
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
        Write-Host 'Working Directory Changed: ' -ForegroundColor Green -NoNewline
        Write-Host "$($PathName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }


} #end Function
