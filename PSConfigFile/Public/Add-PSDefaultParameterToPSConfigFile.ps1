
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

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\temp\PSLauncherConfig.json

#>
Function Add-PSDefaultParameterToPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Function,
		[string]$Parameter,
		[string]$Value
	)

try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$userdata = [PSCustomObject]@{
		Owner             = $json.Userdata.Owner
		CreatedOn         = $json.Userdata.CreatedOn
		PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
		Path              = $json.Userdata.Path
		Hostname          = $json.Userdata.Hostname
		PSEdition         = $json.Userdata.PSEdition
		OS                = $json.Userdata.OS
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = (Get-Date -Format u)
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = "Add PSDefaultParameter $($Name)"
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}
	[System.Collections.generic.List[PSObject]]$PSDefaultObject = @()
	if ($Json.PSDefaults.psobject.Properties.name -like 'Default' -and
		$Json.PSDefaults.psobject.Properties.value -like 'Default') {
		
	[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	} else {
		$Json.PSDefaults | ForEach-Object {[void]$PSDefaultObject.Add($_)}
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	}
	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $Json.PSDrive
		PSAlias     = $Json.PSAlias
		PSCreds     = $Json.PSCreds
		PSDefaults  = $PSDefaultObject
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	try {
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
		Write-Output 'PSDefaults Added'
		Write-Output "ConfigFile: $($confile.FullName)"
	} catch { Write-Error "Error: `n $_" }
} #end Function
