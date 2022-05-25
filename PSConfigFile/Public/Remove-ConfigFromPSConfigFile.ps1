
<#PSScriptInfo

.VERSION 0.1.0

.GUID dd6d4e7a-509e-423e-a972-f0e1a1c34b94

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
Created [22/05/2022_07:47] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Will display existing config with the option to remove it from the config file 

#> 


<#
.SYNOPSIS
Will display existing config with the option to remove it from the config file

.DESCRIPTION
Will display existing config with the option to remove it from the config file

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Remove-ConfigFromPSConfigFile -Export HTML -ReportPath C:\temp

#>
Function Remove-ConfigFromPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[switch]$Variable,
		[switch]$PSDrive,
		[switch]$Alias
	)

	try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}
	[System.Collections.ArrayList]$JsonConfig = @()
	$JsonConfig.Add((Get-Content $confile.FullName -Raw | ConvertFrom-Json))
	$UpdateConfig = $()

	function DisplayMenu {
		PARAM($Object)
		Write-Color 'Select' -Color Yellow -LinesAfter 1
		$index = 0
		foreach ($item in $Object) {
			Write-Color "($($index))", "$($item)" -Color Yellow, Green
			$index++
		}
		$Answer = Read-Host 'Answer'
		return $Object[$Answer]
	}
	
	if ($Variable) {
		$SetVar = @{}
		$CurrentConfig = ($JsonConfig.SetVariable.PSObject.Properties).Name
		$RemoveConfig = DisplayMenu $CurrentConfig

		$members = $JsonConfig.SetVariable | Get-Member -MemberType NoteProperty | Where-Object {$_.name -notlike $RemoveConfig}
		foreach ($mem in $members) {
			$SetVar += @{
				$mem.Name = $JsonConfig.SetVariable.$($mem.Name)
			}
		}
		$UpdateConfig = [psobject]@{
			Userdata    = $JsonConfig.Userdata
			PSDrive     = $JsonConfig.PSDrive
			PSAlias     = $JsonConfig.PSAlias
			PSCreds     = $JsonConfig.PSCreds
			SetLocation = $JsonConfig.SetLocation
			SetVariable = $SetVar
			Execute     = $JsonConfig.Execute
		}
		try {
			$UpdateConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
			Write-Output 'Variable Removed'
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }

	}
	if ($PSDrive) {
		$SetDrive = @{}
		$CurrentConfig = ($JsonConfig.PSDrive.PSObject.Properties).Name
		$RemoveConfig = DisplayMenu $CurrentConfig

		$members = $JsonConfig.PSDrive | Get-Member -MemberType NoteProperty | Where-Object {$_.name -notlike $RemoveConfig}
		foreach ($mem in $members) {
			$SetDrive += @{
				$mem.Name = $JsonConfig.PSDrive.$($mem.Name)
			}
		}
		$UpdateConfig = [psobject]@{
			Userdata    = $JsonConfig.Userdata
			PSDrive     = $SetDrive
			PSAlias     = $JsonConfig.PSAlias
			PSCreds     = $JsonConfig.PSCreds
			SetLocation = $JsonConfig.SetLocation
			SetVariable = $JsonConfig.SetVariable
			Execute     = $JsonConfig.Execute
		}
		try {
			$UpdateConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
			Write-Output 'PSDrive Removed'
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }

	}
	if ($Alias) {
		$SetAlias = @{}
		$CurrentConfig = ($JsonConfig.PSAlias.PSObject.Properties).Name
		$RemoveConfig = DisplayMenu $CurrentConfig

		$members = $JsonConfig.PSAlias | Get-Member -MemberType NoteProperty | Where-Object {$_.name -notlike $RemoveConfig}
		foreach ($mem in $members) {
			$SetAlias += @{
				$mem.Name = $JsonConfig.PSAlias.$($mem.Name)
			}
		}
		$UpdateConfig = [psobject]@{
			Userdata    = $JsonConfig.Userdata
			PSDrive     = $JsonConfig.PSDrive
			PSAlias     = $SetAlias
			PSCreds     = $JsonConfig.PSCreds
			SetLocation = $JsonConfig.SetLocation
			SetVariable = $JsonConfig.SetVariable
			Execute     = $JsonConfig.Execute
		}
		try {
			$UpdateConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
			Write-Output 'Alias Removed'
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }
	}



} #end Function
