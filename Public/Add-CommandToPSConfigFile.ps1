
<#PSScriptInfo

.VERSION 1.1.4

.GUID 98459c57-e214-4a9f-b523-efa2329a0340

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
Created [04/10/2021_19:05] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:31] Added PSDrive Script
Updated [13/11/2021_16:30] Added Alias Script

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

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER ScriptBlockName
Name for the script block

.PARAMETER ScriptBlock
The commands to be executed

.EXAMPLE
Add-CommandToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -ScriptBlockName DriveC -ScriptBlock "get-childitem c:\"

#>
Function Add-CommandToPSConfigFile {
    [Cmdletbinding()]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    ## TODO Allow user to modify the order
    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $Execute = @{}
    if ($Json.Execute.Default -eq 'Default') {
        $Execute += @{
            "[0]-$ScriptBlockName" = $($ScriptBlock.ToString())
        }
    }
    else {
        $Index = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name | Select-Object -Last 1
        [int]$NewTaskIndex = [int]($Index | ForEach-Object { $_.name.split('-')[0].replace('[', '').replace(']', '') }) + 1
        $NewScriptBlockName = '[' + $($NewTaskIndex.ToString()) + ']-' + $ScriptBlockName
        $members = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name
        foreach ($mem in $members) {
            $Execute += @{
                $mem.Name = $json.Execute.$($mem.Name)
            }
        }
        $Execute += @{
            $NewScriptBlockName = $($ScriptBlock.ToString())
        }
    }
    $Update = [psobject]@{
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force




} #end Function
