
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


.EXAMPLE
Remove-ConfigFromPSConfigFile -PSDrive "Temp"

#>
Function Remove-ConfigFromPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
	PARAM(
		[string[]]$Variable,
		[string[]]$PSDrive,
		[string[]]$PSAlias,
        [string[]]$Command,
        [string[]]$Credential,
        [switch]$Location
	)

	try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}
	[System.Collections.Generic.List[pscustomobject]]$JsonConfig = @()
	$JsonConfig.Add((Get-Content $confile.FullName | ConvertFrom-Json))

    if (-not([string]::IsNullOrEmpty($Variable))) {$JsonConfig.SetVariable.PSObject.properties | Where-Object {$_.name -notlike $Variable} | ForEach-Object {$SetVariable += @{$_.name = $_.value}}}
    else {$SetVariable =  $JsonConfig.setvariable}

    if (-not([string]::IsNullOrEmpty($PSDrive))) {$JsonConfig.PSDrive.PSObject.properties | Where-Object {$_.name -notlike $PSDrive} | ForEach-Object {$SetPSDrive += @{$_.name = $_.value}}}
    else {$SetPSDrive =  $JsonConfig.PSDrive}

    if (-not([string]::IsNullOrEmpty($PSAlias))) { $JsonConfig.PSAlias.PSObject.Properties | Where-Object {$_.name -notlike "$PSAlias"}| ForEach-Object {$SetPSAlias += @{$_.name = $_.value}}}
    else {$SetPSAlias =  $JsonConfig.PSAlias}

    if (-not([string]::IsNullOrEmpty($Command))) { $JsonConfig.Execute.PSObject.Properties | Where-Object {$_.name -notlike "$Command"}| ForEach-Object {$SetExecute += @{$_.name = $_.value}}}
    else {$SetExecute =  $JsonConfig.Execute}

    if (-not([string]::IsNullOrEmpty($Credential))) { $JsonConfig.PSCreds.PSObject.Properties | Where-Object {$_.name -notlike "$Credential"} | ForEach-Object {$SetCreds += @{$_.name = $_.value}}}
    else {$SetCreds =  $JsonConfig.PSCreds}

    if ($Location) {$SetLocation = @{}}
    else {$SetLocation =  $JsonConfig.SetLocation}
    

    $Update = @()
    $Update = [psobject]@{
        Userdata    = $JsonConfig.Userdata
        PSDrive     = $SetPSDrive
        PSAlias     = $SetPSAlias
        PSCreds     = $SetCreds
        SetLocation = $SetLocation
        SetVariable = $SetVariable
        Execute     = $SetExecute
     }

		try {
			$Update | ConvertTo-Json | Set-Content -Path $confile.FullName -Force
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }
} #end Function
