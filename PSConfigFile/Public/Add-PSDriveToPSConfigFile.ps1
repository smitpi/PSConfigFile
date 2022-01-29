
<#PSScriptInfo

.VERSION 1.0.2

.GUID 0fcfdc24-96af-490f-a636-3a8a6bfb4ece

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

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
Updated [13/11/2021_16:30] Added Alias Script

.PRIVATEDATA

#>





<#

.DESCRIPTION
Add PSDrive to the config file

#>


<#
.SYNOPSIS
Add PSDrive to the config file.

.DESCRIPTION
Add PSDrive to the config file.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER DriveName
Name of the PSDrive (PSDrive needs to be created first with New-PSDrive)

.EXAMPLE
Add-PSDriveToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -DriveName TempDrive

#>
Function Add-PSDriveToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateScript( { ( Get-PSDrive $_) })]
        [string]$DriveName
    )
    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $SetPSDrive = @{}
    $InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name,Root
    if ($null -eq $InputDrive) {Write-Error "Unknown psdrive";break}
    if ($Json.PSDrive.Default -eq 'Default') {
        $SetPSDrive = @{
            $InputDrive.Name = $InputDrive
        }
    }
    else {
        $members = $Json.PSDrive | Get-Member -MemberType NoteProperty
        foreach ($mem in $members) {
            $SetPSDrive += @{
                $mem.Name = $json.PSDrive.$($mem.Name)
            }
        }
        $SetPSDrive += @{
            $InputDrive.Name = $InputDrive
        }
    }

    $Update = [psobject]@{
        Userdata    = $Json.Userdata
        PSDrive     = $SetPSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
} #end Function

