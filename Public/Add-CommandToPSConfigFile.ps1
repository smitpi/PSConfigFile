
<#PSScriptInfo

.VERSION 1.1.2

.GUID 98459c57-e214-4a9f-b523-efa2329a0340

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
Add a command to the config file

#> 

Param()


Function Add-CommandToPSConfigFile {
	[Cmdletbinding()]
                PARAM(
                [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
				[System.IO.FileInfo]$ConfigFile,
                [string]$ScriptBlockName,
				[string]$ScriptBlock,
				[int]$ExecutionOrder
				)

	try {
		$confile = Get-Item $ConfigFile
		Test-Path -Path $confile.FullName
	} catch { throw 'Incorect file' }
	## TODO Force the execution order
	## TODO Allow user to modify the order
	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
		$Update = @()
		$Execute = @{}
		if ($Json.Execute.Default -eq 'Default') {
			$Execute += @{
				"[0]-$ScriptBlockName" = $($ScriptBlock.ToString())
			}
		} else {
			$Index = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name | Select-Object -Last 1
			[int]$NewTaskIndex = [int]($Index | ForEach-Object {$_.name.split("-")[0].replace("[","").replace("]","")}) +1
			$NewScriptBlockName = "[" + $($NewTaskIndex.ToString()) + "]-" + $ScriptBlockName
			$members = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name
			foreach ($mem in $members) {
				$Execute += @{
					$mem.Name = $json.Execute.$($mem.Name)
				}
			}
			$Execute += @{
				$NewScriptBlockName = $($ScriptBlock.ToString())
			}
		}
		$Update = [psobject]@{
			Userdata    = $Json.Userdata
			SetLocation = $Json.SetLocation
			SetVariable = $Json.SetVariable 
			Execute     = $Execute
		}
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force




} #end Function
