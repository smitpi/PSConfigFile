
<#PSScriptInfo

.VERSION 0.1.0

.GUID d9eca5db-a20b-4785-8086-6b8284d0a2a1

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS los

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [18/08/2022_09:33] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Export the PFX file for credentials 

#> 


<#
.SYNOPSIS
Export the PFX file for credentials.

.DESCRIPTION
Export the PFX file for credentials.

.PARAMETER Path
Path where the pfx will be saved.

.PARAMETER Credential
Credential used to export the pfx file.

.EXAMPLE
$creds = Get-Credential
Export-PSConfigFilePFX -Path C:\temp -Credential $creds

#>
Function Export-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(Mandatory)]
		[System.IO.DirectoryInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName PFXExport -Message 'For the exported pfx file')
	)

	$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	if (-not($selfcert)) { Write-Warning 'Certificate does not exist, nothing to export'}
	else {
		if (Test-Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')) {
			Rename-Item -Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"
		}
		$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $Credential.Password -FilePath (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx')
	}

} #end Function
