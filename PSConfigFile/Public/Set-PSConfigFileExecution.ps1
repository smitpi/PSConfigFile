
<#PSScriptInfo

.VERSION 0.1.1

.GUID e01db8ba-089a-4bbf-a255-4db496569215

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
Created [18/11/2021_08:26] Initial Script Creating
Updated [18/11/2021_08:31] Changed the update script to Set-PSConfigFileExecution

#>




<#

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

#>


<#
.SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER PSProfile
Enable or disable loading of config when your ps profile is loaded.

.PARAMETER PSModule
Enable or disable loading of config when a specific module is loaded.

.PARAMETER PathToPSM1File
Path to the .psm1 file

.PARAMETER ExecuteNow
Execute the config file, to make sure everything runs as expected.

.EXAMPLE
Set-PSConfigFileExecution -ConfigFile C:\Temp\jdh\PSCustomConfig.json -PSProfile AddScript -PSModule AddScript -PathToPSM1File C:\Utils\LabScripts\LabScripts.psm1

#>
Function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSModule = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
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

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        $string = @"

#PSConfigFile
`$PSConfigFileModule = get-item `"$((Join-Path $module.ModuleBase \PSConfigFile.psm1 -Resolve))`" #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile
"@

        if ($PSModule -like 'AddScript') {

            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*#PSConfigFile*' }
            Set-Content -Value ($ori + $string) -Path $PathToPSM1File -Verbose

        }
        if ($PSModule -like 'RemoveScript') {
            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*#PSConfigFile*' }
            Set-Content -Value ($ori) -Path $PathToPSM1File -Verbose
        }
        if ($PSProfile -like 'AddScript') {

            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $vs -Verbose
            }

        }
        if ($PSProfile -like 'RemoveScript') {
            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $vs -Verbose
            }


        }
        if ($ExecuteNow) {
            Clear-Host
            Invoke-PSConfigFile -ConfigFile $($confile.FullName)
        }

    }


} #end Function

