
<#PSScriptInfo

.VERSION 0.1.1

.GUID e01db8ba-089a-4bbf-a255-4db496569215

.AUTHOR Pierre Smit

.COMPANYNAME Private

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
<#
.SYNOPSIS
Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.

.DESCRIPTION
This function adds or removes the command to invoke your PSConfigFile configuration from your PowerShell profile or a specified module. This ensures your environment is set up automatically every time you start a new session. You can also choose to include the DisplayOutput parameter for verbose startup information.

.PARAMETER PSProfile
Specifies whether to add or remove the config execution command from your PowerShell profile. Accepts values like 'AddScript' or 'RemoveScript'.

.PARAMETER DisplayOutput
If specified, adds the DisplayOutput parameter to the invoke command in your profile for detailed output at startup.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
Adds the config execution command with detailed output to your PowerShell profile.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile RemoveScript
Removes the config execution command from your PowerShell profile.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to automate your environment setup every time you launch PowerShell.
#>

function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'AddScript',
        [switch]$DisplayOutput
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        if ($DisplayOutput) {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`"  -DisplayOutput #PSConfigFile

"@
        } else {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile

"@
        }


        if ($PSProfile -like 'AddScript') {

            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8
                Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }
        if ($PSProfile -like 'RemoveScript') {
            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Write-Host '[Removed]' -NoNewline -ForegroundColor Yellow; Write-Host ' From Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }

    }
} #end Function

