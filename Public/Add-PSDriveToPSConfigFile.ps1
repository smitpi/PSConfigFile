
<#PSScriptInfo

.VERSION 1.0.1

.GUID 0fcfdc24-96af-490f-a636-3a8a6bfb4ece

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
Created [14/10/2021_13:56] Initital Script Creating
Updated [14/10/2021_19:32] Added PSDrive Script

.PRIVATEDATA

#> 



<#

.DESCRIPTION 
Add PSDrive to the config file

#>

Param()

#.ExternalHelp PSConfigFile-help.xml
Function Add-PSDriveToPSConfigFile {
	[Cmdletbinding()]
	PARAM(
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$ConfigFile,
		[ValidateScript( { ( Get-PSDrive $_) })]
		[string]$DriveName
	)
	try {
		$confile = Get-Item $ConfigFile
		Test-Path -Path $confile.FullName
	} catch { throw 'Incorect file' }

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$Update = @()
	$SetPSDrive = @{}
	$InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name,Root
	if ($null -eq $InputDrive) {Write-Error "Unknown psdrive";break}
	if ($Json.PSDrive.Default -eq 'Default') {
		$SetPSDrive = @{
			$InputDrive.Name = $InputDrive
		}
	} else {
		$members = $Json.PSDrive | Get-Member -MemberType NoteProperty
		foreach ($mem in $members) {
			$SetPSDrive += @{
				$mem.Name = $json.PSDrive.$($mem.Name)
			}
		}
		$SetPSDrive += @{
			$InputDrive.Name = $InputDrive
		}
	}

	$Update = [psobject]@{
		Userdata    = $Json.Userdata
		PSDrive     = $SetPSDrive
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
} #end Function
