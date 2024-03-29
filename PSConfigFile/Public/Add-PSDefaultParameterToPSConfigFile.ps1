
<#PSScriptInfo

.VERSION 0.1.0

.GUID 4a597ee8-f395-4479-9f80-1730b90e0eaf

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
Created [18/08/2022_07:54] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Add PSDefaultParameterValues to the config file 

#> 

<#
.SYNOPSIS
Add PSDefaultParameterValues to the config file

.DESCRIPTION
Add PSDefaultParameterValues to the config file

.PARAMETER Function
The Function to add

.PARAMETER Parameter
The Parameter of that function.

.PARAMETER Value
Value of the parameter.

.PARAMETER Force
Will delete the config file before saving the new one. If false, then the config file will be renamed.


.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\temp\PSLauncherConfig.json

#>
Function Add-PSDefaultParameterToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
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
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = "Add PSDefaultParameter $($Function):$($Parameter)"
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
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
