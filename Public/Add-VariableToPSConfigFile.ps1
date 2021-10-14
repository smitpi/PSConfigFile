
<#PSScriptInfo

.VERSION 1.1.3

.GUID da6df4de-5b05-4796-bf82-345686b30e78

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS powershell ps

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
Updated [14/10/2021_19:32] Added PSDrive Script

.PRIVATEDATA

#> 







<#

.DESCRIPTION 
Add a varible to the config file

#>

Param()
#.ExternalHelp PSConfigFile-help.xml
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
        $inputtype = $InputVar.Value.GetType()
        if ($inputtype.Name -like "PSCredential" -or $inputtype.Name -like "SecureString") {Write-Error "PSCredential or SecureString not allowed"; break}

		if ($Json.SetVariable.Default -eq 'Default') {
			$SetVariable = @{
				$InputVar.Name = $InputVar.Value
			}
		} else {
			$members = $Json.SetVariable | Get-Member -MemberType NoteProperty
			foreach ($mem in $members) {
				$SetVariable += @{
					$mem.Name = $json.SetVariable.$($mem.Name)
				}
			}
			$SetVariable += @{
				$InputVar.Name = $InputVar.Value
			}
		}

		$Update = [psobject]@{
			Userdata    = $Json.Userdata
			PSDrive     = $Json.PSDrive
			SetLocation = $Json.SetLocation
			SetVariable = $SetVariable
			Execute     = $Json.Execute
		}
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
	}
} #end Function
