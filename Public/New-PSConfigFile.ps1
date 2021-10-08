
<#PSScriptInfo

.VERSION 1.1.2

.GUID ec11b3b9-d13e-43c9-8a6d-d42a65016554

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
Created [25/09/2021_02:52] Initital Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
To store your settings

#> 

Param()

Function New-PSConfigFile {
	[Cmdletbinding()]
	param (
		[parameter(Mandatory)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Attributes -eq 'Directory') })]
		[System.IO.DirectoryInfo]$ConfigDir
	)

	# TODO Add logging
	# TODO Add rotation of the logs
	function attr {
		$Userdata = @()
		$SetLocation = @()
		$SetVariable = @()
		$Execute = @()

		$Userdata = New-Object PSObject -Property @{
			Computer    = $env:COMPUTERNAME
			LogonServer = $env:LOGONSERVER
			OS          = $env:OS
			DomainName  = $env:USERDNSDOMAIN
			Userid      = $env:USERNAME
			CreatedOn   = [DateTimeOffset]::Now
		}
		$SetLocation = New-Object PSObject -Property @{}
		$SetVariable = New-Object PSObject -Property @{
			Default = 'Default'
		}
		$Execute = New-Object PSObject -Property @{
			Default = 'Default'
		}
		#main
		New-Object PSObject -Property @{
			Userdata    = $Userdata
			SetLocation = $SetLocation
			SetVariable = $SetVariable
			Execute     = $Execute
		}

	}
	$Fullpath = Get-Item $ConfigDir

	$check = Test-Path -Path (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -ErrorAction SilentlyContinue
	if (-not($check)) {
		Write-Host 'Config File does not exit, creating default settings.' -ForegroundColor Magenta

		$data = attr
		$data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Verbose -Force
	} else { 

		Write-Warning 'File exists, renaming file now'
		Rename-Item (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -NewName "PSCustomConfig_$(Get-Date -Format ddMMyyyy_HHmm).json"

		$data = attr
		$data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Verbose -Force


	}
}
