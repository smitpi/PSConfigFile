
<#PSScriptInfo

.VERSION 1.1.2

.GUID b282e3bd-08f5-41ba-9c63-8306ce5c45a6

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
Created [25/09/2021_08:15] Initital Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Read and execute the config file

#> 

Param()

Function Invoke-PSConfigFile {
		[Cmdletbinding()]
			param (
				[parameter(Mandatory)]
				[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
				[System.IO.FileInfo]$ConfigFile
			)
	## TODO add logging
	$confile = Get-Item $ConfigFile -ErrorAction SilentlyContinue

	Write-Colour 'PSConfigFile Execution Start' -ShowTime -Color DarkCyan -LinesBefore 4
	Write-Colour '#######################################################' -ShowTime -Color Green

	$JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`":  `"Default`"" }) | ConvertFrom-Json
	if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
	Write-Colour 'Using PSCustomConfig file: ', $($confile.fullname) -ShowTime -Color DarkCyan, DarkYellow
    
	Write-Colour 'Details of Config File:' -ShowTime -Color DarkCyan -LinesAfter 1 -LinesBefore 1
	$JSONParameter.Userdata.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

	if ($JSONParameter.SetLocation.WorkerDir -like $true) {
		Write-Colour 'Setting Folder Location: ',$($JSONParameter.SetLocation.WorkerDir) -ShowTime -Color DarkCyan,DarkYellow -LinesAfter 1 -LinesBefore 1
		Set-Location $JSONParameter.SetLocation.WorkerDir -ErrorAction SilentlyContinue
	}

	Write-Colour 'Setting Default Variables:' -ShowTime -Color DarkCyan -LinesBefore 1 -LinesAfter 1
	$JSONParameter.SetVariable.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope global }
	New-Variable -Name 'ConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force

	Write-Colour 'Executing Custom Commands: ' -ShowTime -Color DarkCyan -LinesBefore 1 -LinesAfter 1
	$JSONParameter.execute.PSObject.Properties  | select name,value | Sort-Object -Property Name | ForEach-Object { 
		$tmp = $null
		Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime
		Write-Color 'ScriptBlock Output:' -Color Yellow -ShowTime -LinesBefore 1 -LinesAfter 1
		$tmp = [scriptblock]::Create($_.value)
		$tmp.invoke()
	}
	Write-Colour '#######################################################' -ShowTime -Color Green -LinesBefore 1
	Write-Colour 'PSConfigFile Execution End' -ShowTime -Color DarkCyan -LinesAfter 1

	$xml = ($env:computername) + "-" +(Get-Date -f "yyyy_MMddhhmm") + ".xml"
	$export = Join-Path -path C:\temp -ChildPath $xml
	$PSCmdlet.GetVariableValue($PSBoundParameters["InformationVariable"]) |	Export-Clixml $export
} #end Function
