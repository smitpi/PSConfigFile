
<#PSScriptInfo

.VERSION 0.1.1

.GUID e01db8ba-089a-4bbf-a255-4db496569215

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

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



#Requires -Module PSWriteColor

<#

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

#>


<#
.SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

.PARAMETER PSProfile
Enable or disable loading of config when your ps profile is loaded.

.PARAMETER PSModule
Enable or disable loading of config when a specific module is loaded.

.PARAMETER ModuleName
Name of the module to be updated.
If the module is not in the standard folders ($env:PSModulePath), then import it into your session first.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile AddScript -PSModule AddScript -ModuleName LabScripts

#>
Function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSModule = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [ValidateScript( {
                $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -and ([bool](Get-Module $_) -or ([bool](Get-Module $_ -ListAvailable)))) { $True }
                else { Throw 'Invalid Module name and you must be running an elevated prompt to use this fuction.' } })]
        [string]$ModuleName
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
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        $string = @"
#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$(`$PSConfigFileModule.FullName) -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile
"@

        if ($PSModule -like 'AddScript') {
            try {
                $ModModules = Get-Module $ModuleName
                if (-not($ModModules)) { $ModModules = Get-Module $ModuleName -ListAvailable }
                if (-not($ModModules)) { throw 'Module not found' }

                foreach ($ModModule in $ModModules) {

                    if (-not(Test-Path -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile'))) { $PSConfigFilePath = New-Item -Path $ModModule.ModuleBase -Name PSConfigFile -ItemType Directory }
                    else { $PSConfigFilePath = Get-Item (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile') }

                    if (-not(Test-Path (Join-Path $PSConfigFilePath.FullName -ChildPath 'PSConfigFile_ScriptToProcess.ps1'))) {
                        $string | Set-Content -Path (Join-Path $PSConfigFilePath.FullName -ChildPath 'PSConfigFile_ScriptToProcess.ps1') -Force
                    }

                    $ModModuleManifest = Test-ModuleManifest -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath "\$($ModModule.Name).psd1")
                    [System.Collections.ArrayList]$newScriptsToProcess = @()
                    foreach ($Scripts in $ModModuleManifest.Scripts) {
                        $ScriptPath = Get-Item $Scripts
                        [void]$newScriptsToProcess.Add("$(($ScriptPath.Directory).Name)\$($ScriptPath.Name)")
                    }


                    [void]$newScriptsToProcess.Add('PSConfigFile\PSConfigFile_ScriptToProcess.ps1')
                    Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess $newScriptsToProcess
                    Write-Color '[Updated]', 'Modulename: ', $ModuleName -Color Cyan, Gray, Yellow
                }
            }
            catch { Write-Error "Unable to update Module Manifest: `n $_" }

        }
        if ($PSModule -like 'RemoveScript') {
            try {
                $ModModules = Get-Module $ModuleName
                if (-not($ModModules)) { $ModModules = Get-Module $ModuleName -ListAvailable }
                if (-not($ModModules)) { throw 'Module not found' }

                foreach ($ModModule in $ModModules) {
                    $ModModuleManifest = Test-ModuleManifest -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath "\$($ModModule.Name).psd1")
                    [System.Collections.ArrayList]$newScriptsToProcess = @()
                    foreach ($Scripts in ($ModModuleManifest.Scripts | Where-Object { $_ -notlike '*PSConfigFile*' })) {
                        $ScriptPath = Get-Item $Scripts
                        [void]$newScriptsToProcess.Add("$(($ScriptPath.Directory).Name)\$($ScriptPath.Name)")
                    }

                    if ($null -like $newScriptsToProcess ) {
                        $null = New-Item -Path $ModModule.ModuleBase -Name 'empty.ps1' -ItemType File -Value '# Because Update-ModuleManifest cant have empty ScriptsToProcess values'
                        Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess 'empty.ps1'
                    }
                    else {
                        Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess $newScriptsToProcess
                    }
                    if (Test-Path -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile')) { Remove-Item -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile') -Recurse -Force }
                    Write-Color '[Removed]', 'Modulename: ', $ModuleName -Color Cyan, Gray, Yellow
                }
            }
            catch { Write-Error "Unable to update Module Manifest: `n $_" }
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
                Set-Content -Value ($ori + $string) -Path $ps
                Write-Color '[Updated]', 'Profile: ', $ps -Color Cyan, Gray, Yellow
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ise
                Write-Color '[Updated]', 'Profile: ', $ise -Color Cyan, Gray, Yellow
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $vs
                Write-Color '[Updated]', 'Profile: ', $vs -Color Cyan, Gray, Yellow
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
                Set-Content -Value ($ori) -Path $ps
                Write-Color '[Removed]', 'Profile: ', $ps -Color Cyan, Gray, Yellow
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ise
                Write-Color '[Removed]', 'Profile: ', $ise -Color Cyan, Gray, Yellow
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $vs
                Write-Color '[Removed]', 'Profile: ', $vs -Color Cyan, Gray, Yellow
            }


        }
    }
} #end Function

