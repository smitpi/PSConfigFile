
<#PSScriptInfo

.VERSION 0.1.0

.GUID 4a597ee8-f395-4479-9f80-1730b90e0eaf

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
Created [18/08/2022_07:54] Initial Script Creating

.PRIVATEDATA

#>

<#
.SYNOPSIS
Adds a default parameter value for a function to the PSConfigFile configuration.

.DESCRIPTION
This function allows you to specify default parameter values for any PowerShell function. These defaults are stored in your configuration file and will be automatically applied in your session, saving you from repeatedly specifying common parameters. Wildcards can be used to apply defaults to multiple functions or parameters.

.PARAMETER Function
The name of the function to add a default parameter for. Wildcards are supported to match multiple functions.

.PARAMETER Parameter
The name of the parameter to set a default value for. Wildcards are supported to match multiple parameters.

.PARAMETER Value
The value to assign as the default for the specified parameter.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\\temp\\PSLauncherConfig.json
Sets a default value for the 'PSLauncherConfigFile' parameter of the 'Start-PSLauncher' function.

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function *-Item -Parameter Path -Value C:\\Data -Force
Sets a default 'Path' for all functions ending with '-Item', overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to streamline your PowerShell workflow with persistent default parameters.
#>
function Add-PSDefaultParameterToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile')]
	[OutputType([System.Object[]])]
	param(
		[Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Name of a function to add, You can use wildcards to apply to more functions.')]
		[string]$Function,
		[Parameter(Position = 1, Mandatory = $true, HelpMessage = 'Name of a parameter to add, You can use wildcards to apply to more parameters.')]
		[string]$Parameter,
		[Parameter(Position = 2, Mandatory = $true, HelpMessage = 'The Value to add.')]
		[string]$Value,
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
			ModifiedAction = "Add PSDefaultParameter $($Function):$($Parameter)"
		}
	}
	[System.Collections.generic.List[PSObject]]$PSDefaultObject = @()
	if ([string]::IsNullOrEmpty($XMLData.PSDefaults)) {
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	} else {
		$XMLData.PSDefaults | ForEach-Object {[void]$PSDefaultObject.Add($_)}
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	}
	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $XMLData.PSDrive
		PSFunction  = $XMLData.PSFunction
		PSCreds     = $XMLData.PSCreds
		PSDefaults  = ($PSDefaultObject | Where-Object {$_ -notlike $null})
		SetLocation = $XMLData.SetLocation
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
		Write-Host 'PSDefault Added: ' -ForegroundColor Green -NoNewline
		Write-Host "$($Function):$($Parameter)" -ForegroundColor Yellow
		Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
	} catch { Write-Error "Error: `n $_" }
} #end Function
