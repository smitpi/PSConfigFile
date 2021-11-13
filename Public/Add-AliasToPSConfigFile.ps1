
<#PSScriptInfo

.VERSION 0.1.1

.GUID c3886845-ff95-4e7c-9284-5b297fcb102a

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
Created [13/11/2021_15:18] Initial Script Creating
Updated [13/11/2021_16:30] Added Alias Script

.PRIVATEDATA

#>



<#

.DESCRIPTION
Add alias to the config file.

#>


<#
.SYNOPSIS
Creates Shortcuts (Aliases) to commands or script blocks

.DESCRIPTION
Creates Shortcuts (Aliases) to commands or script blocks

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER AliasName
Name to use for the command

.PARAMETER CommandToRun
Command to run in a string format

.EXAMPLE
Add-AliasToPSConfigFile -ConfigFile $PSConfigFile -AliasName psml -CommandToRun "import-module .\*.psm1 -force -verbose"

#>
Function Add-AliasToPSConfigFile {
    [Cmdletbinding()]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateNotNullOrEmpty()]
        [string]$AliasName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json

    $Update = @()
    $SetAlias = @{}

    if ($Json.PSAlias.Default -eq 'Default') {
        $SetAlias = @{
            $AliasName = $CommandToRun
        }
    }
    else {
        $members = $Json.SetAlias | Get-Member -MemberType NoteProperty
        foreach ($mem in $members) {
            $SetAlias += @{
                $mem.Name = $json.SetAlias.$($mem.Name)
            }
        }
        $SetAlias += @{
            $AliasName = $CommandToRun
        }
    }

    $Update = [psobject]@{
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $SetAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force

} #end Function
