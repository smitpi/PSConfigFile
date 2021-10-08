
<#PSScriptInfo

.VERSION 1.1.2

.GUID da6df4de-5b05-4796-bf82-345686b30e78

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
Created [04/10/2021_19:05] Initital Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Add a varible to the config file

#> 

Param()

Function Add-VariableToPSConfigFile {
	[Cmdletbinding()]
	PARAM(
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[System.IO.FileInfo]$ConfigFile,
		[ValidateScript( { ( Get-Variable $_) })]
		[string[]]$VariableNames
	)
	try {
		$confile = Get-Item $ConfigFile
		Test-Path -Path $confile.FullName
	} catch { throw 'Incorect file' }

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json

	foreach ($VariableName in $VariableNames) {
		$Update = @()
		$SetVariable = @{}
		$InputVar = Get-Variable -Name $VariableName

		if ($Json.SetVariable.Default -eq 'Default') {
			$SetVariable = @{
				$InputVar.Name = $(Get-Variable -Name $VariableName -ValueOnly)
			}
		} else {
			$members = $Json.SetVariable | Get-Member -MemberType NoteProperty
			foreach ($mem in $members) {
				$SetVariable += @{
					$mem.Name = $json.SetVariable.$($mem.Name)
				}
			}
			$SetVariable += @{
				$InputVar.Name = $(Get-Variable -Name $VariableName -ValueOnly)
			}
		}

		$Update = [psobject]@{
			Userdata    = $Json.Userdata
			SetLocation = $Json.SetLocation
			SetVariable = $SetVariable
			Execute     = $Json.Execute
		}
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
	}
} #end Function
