﻿
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

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER Path
Path or PS Drive to set location to.

.EXAMPLE
Add-LocationToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -Path c:\temp

#>
Function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateScript( { ( Test-Path $_) -or ( Get-PSDrive $_) })]
        [string]$Path
    )
    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }
    try {
        if ([bool](Get-PSDrive $Path) -like $true ) { [string]$AddPath = (Get-PSDrive $Path).name }
        else { [string]$AddPath = (Get-Item $path).FullName }
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
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force

} #end Function
