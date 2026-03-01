
<#PSScriptInfo

.VERSION 1.1.4

.GUID 9f023856-311a-4463-a042-f57955ced2de

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS powershell ps


.DESCRIPTION
Add a start-up location to the config file

#>



<#
.SYNOPSIS
Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

.DESCRIPTION
This function allows you to specify a default working location for your PowerShell session, either as a folder path or a PSDrive. When the config file is invoked, your session will automatically change to this location, streamlining your workflow and ensuring you always start in the right place.

.PARAMETER LocationType
Specifies the type of location to add. Accepts 'PSDrive' for a PowerShell drive or 'Folder' for a filesystem path.

.PARAMETER Path
The path to the folder or the name of the PSDrive to set as the default location. Must exist as a valid path or drive.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType PSDrive -Path temp
Sets the default location to the 'temp' PSDrive when the config is invoked.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType Folder -Path c:\\temp
Sets the default location to the 'c:\\temp' folder when the config is invoked.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to ensure your PowerShell session always starts in the correct directory or drive.
#>

function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    param(
        [Parameter(Mandatory = $true)]
        [validateSet('PSDrive', 'Folder')]
        [string]$LocationType,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { ( Test-Path $_) -or ( [bool](Get-PSDrive $_)) })]
        [string]$Path,
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
    try {
        if ($LocationType -like 'PSDrive') {
            Get-PSDrive $Path -ErrorAction Stop | Out-Null
            [string]$AddPath = "$($path)"
        }
        if ($LocationType -like 'Folder') {
            [string]$AddPath = (Get-Item $path -ErrorAction Stop).FullName
        }
    } catch { throw 'Could not find path' }

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
            ModifiedAction = "Working Directory Changed: $($Path)"
        }
    }

    $Update = @()
    $SetLocation = @{}
    $SetLocation += @{
        WorkerDir = $($AddPath)
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
        Write-Host "$($Path)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }

} #end Function
