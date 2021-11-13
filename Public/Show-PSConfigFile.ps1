
<#PSScriptInfo

.VERSION 0.1.0

.GUID 781274ac-332b-4346-bc72-2a586fa20ed6

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
Created [13/11/2021_21:22] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Display what's configured in the config file 

#> 


<#
.SYNOPSIS
Display what's configured in the config file.

.DESCRIPTION
Display what's configured in the config file. But doesn't execute the commands

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.EXAMPLE
Show-PSConfigFile -ConfigFile $PSConfigFile

#>
Function Show-PSConfigFile {
 [Cmdletbinding()]
	param (
		[parameter(Mandatory)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$ConfigFile
	)
	try {
		$confile = Get-Item $ConfigFile -ErrorAction SilentlyContinue

		Write-Color 'PSConfigFile' -ShowTime -Color DarkCyan -LinesBefore 4
		Write-Color '#######################################################' -ShowTime -Color Green 

		$JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
		if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
		Write-Color 'Using PSCustomConfig file: ', $($confile.fullname) -ShowTime -Color DarkCyan, DarkYellow 

		# User Data
		Write-Color 'Details of Config File:' -ShowTime -Color DarkCyan -LinesBefore 1 
		$JSONParameter.Userdata.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -StartTab 4 }

		# Set Location
		if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
			Write-Color 'Setting Folder Location: ', $($JSONParameter.SetLocation.WorkerDir) -ShowTime -Color DarkCyan, DarkYellow -LinesBefore 1 
		}

		#Set Variables
		Write-Color 'Setting Default Variables:' -ShowTime -Color DarkCyan -LinesBefore 1 
		$JSONParameter.SetVariable.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color ime }
		Write-Color 'PSConfigFilePath', ':', ($confile.Directory).FullName -Color Yellow, DarkCyan, Green -ShowTime
		Write-Color 'PSConfigFile', ':', $confile.FullName -Color Yellow, DarkCyan, Green -ShowTime

		# Set PsDrives
		Write-Color 'Creating PSDrives:' -ShowTime -Color DarkCyan -LinesBefore 1 
		$JSONParameter.PSDrive.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value.root -Color Yellow, DarkCyan, Green -ShowTime }

		# Set Alias
		Write-Color 'Creating Custom Aliases: ' -ShowTimerkCyan -LinesBefore 1 
		$JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

		# Execute Commands
		Write-Color 'Executing Custom Commands: ' -ShowTime -Color DarkCyan -LinesBefore 1 
		$JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

		Write-Color '#######################################################' -ShowTime -Color Green -LinesBefore 1 
		Write-Color 'PSConfigFile Execution End' -ShowTime -Color DarkCyan 
	}
	catch {
		Write-Warning $_.Exception 
		Write-Warning $_.Exception.message 
	}
} #end Function