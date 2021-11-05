
<#PSScriptInfo

.VERSION 1.1.3

.GUID 41acb0b5-43ed-42b4-8f58-55509cf88189

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
Created [25/09/2021_13:12] Initital Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:52] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script

.PRIVATEDATA

#>







<#

.DESCRIPTION
updates the json file

#>


#.ExternalHelp PSConfigFile-help.xml
Function Update-PSConfigFile {
    <#
.SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER AddToProfile
Enable or disable loading of config when your ps profile is loaded.

.PARAMETER AddToModule
Enable or disable loading of config when a specific module is loaded.

.PARAMETER PathToPSM1File
Path to the .psm1 file

.PARAMETER ExecuteNow
Execute the config file, to make sure everything runs as expected.

.EXAMPLE
Update-PSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -AddToProfile AddScript -AddToModule AddScript -PathToPSM1File C:\Utils\LabScripts\LabScripts.psm1

#>
    [Cmdletbinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [validateSet('AddScript', 'RemoveScript', 'Ignore')]
        [string]$AddToProfile = $false,
        [validateSet('AddScript', 'RemoveScript', 'Ignore')]
        [string]$AddToModule = 'Ignore',
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psm1') })]
        [System.IO.FileInfo]$PathToPSM1File,
        [switch]$ExecuteNow = $false
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
        $resolve = Join-Path (Get-Module PSConfigFile).ModuleBase '\PSConfigFile.psm1' -Resolve
        $string = @("import-module $resolve -force ") #PSConfigFile")
        $string += @("Invoke-PSConfigFile -ConfigFile $($confile.FullName)")

        if ($AddToModule -like 'AddScript') {

            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*PSConfigFile*' }
            Set-Content -Value ($ori + $string) -Path $PathToPSM1File -Verbose

        }
        if ($AddToModule -like 'RemoveScript') {
            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*PSConfigFile*' }
            Set-Content -Value ($ori) -Path $PathToPSM1File -Verbose
        }
        if ($AddToProfile -like 'AddScript') {

            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $vs -Verbose
            }

        }
        if ($AddToProfile -like 'RemoveScript') {
            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*PSConfigFile*' }
                Set-Content -Value ($ori) -Path $vs -Verbose
            }


        }
        if ($ExecuteNow) {
            Clear-Host
            Invoke-PSConfigFile -ConfigFile $($confile.FullName)
        }

    }


} #end Function
