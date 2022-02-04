
<#PSScriptInfo

.VERSION 1.1.4

.GUID 9f023856-311a-4463-a042-f57955ced2de

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
Created [04/10/2021_19:06] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Alias Script

.PRIVATEDATA

#>









<#

.DESCRIPTION
Add a start-up location to the config file

#>



<#
.SYNOPSIS
Adds default location to the config file.

.DESCRIPTION
Adds default location to the config file.

.PARAMETER LocationType
Is the location a folder or a PS-Drive.

.PARAMETER Path
Path to the folder or the PS-Drive name.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType PSDrive -Path temp

.EXAMPLE
Add-LocationToPSConfigFile -LocationType Folder -Path c:\temp

#>
Function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [validateSet('PSDrive', 'Folder')]
        [string]$LocationType,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { ( Test-Path $_) -or ( [bool](Get-PSDrive $_)) })]
        [string]$Path
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    try {
        if ($LocationType -like 'PSDrive') {
            $check = Get-PSDrive $Path -ErrorAction Stop
            [string]$AddPath = "$($path)"
        }
        if ($LocationType -like 'Folder') {
            [string]$AddPath = (Get-Item $path).FullName
        }
    }
    catch { throw 'Could not find path' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $SetLocation = @{}
    $SetLocation += @{
        WorkerDir = $($AddPath)
    }
    $Update = [psobject]@{
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Location added'
        Write-Output "ConfigFile: $($confile.FullName)"
    }
    catch { Write-Error "Error: `n $_" }

} #end Function
