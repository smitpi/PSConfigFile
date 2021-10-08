
<#PSScriptInfo

.VERSION 1.1.2

.GUID 9f023856-311a-4463-a042-f57955ced2de

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [04/10/2021_19:06] Initital Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Add a startup location to the config file

#> 

Param()



Function Add-LocationToPSConfigFile {
	[Cmdletbinding()]
	PARAM(
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$ConfigFile,
		[ValidateScript( { ( Test-Path $_) })]
		[System.IO.Directory]$Path
	)
	try {
		$confile = Get-Item $ConfigFile
		Test-Path -Path $confile.FullName
	} catch { throw 'Incorect file' }

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$Update = @()

	$SetLocation = @{}
	$SetLocation += @{
		WorkerDir = $((Get-Item $path).FullName)
	}
	$Update = [psobject]@{
		Userdata    = $Json.Userdata
		SetLocation = $SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force

} #end Function
