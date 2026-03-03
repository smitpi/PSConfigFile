
<#PSScriptInfo

.VERSION 1.1.5

.GUID d9eca5db-a20b-4785-8086-6b8284d0a2a1

.AUTHOR Pierre Smit

.COMPANYNAME Private

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
Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.

.DESCRIPTION
Use this function to export the self-signed certificate (in PFX format) that is used to encrypt and decrypt credentials in your PSConfigFile configuration. Exporting the certificate allows you to import it on other machines, enabling secure decryption of credentials across trusted systems. You must provide a credential to protect the exported PFX file.

.PARAMETER Path
The directory path where the exported PFX file will be saved. The directory will be created if it does not exist.

.PARAMETER Credential
The credential (username and password) used to protect the exported PFX file. Use Get-Credential to create this object.

.EXAMPLE
$creds = Get-Credential
Export-PSConfigFilePFX -Path C:\temp -Credential $creds
Exports the certificate to C:\temp, protected by the provided credentials.

#>
function Export-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	param(
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
		if (Test-Path (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx')) {
			Rename-Item -Path (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"
		}
		$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $Credential.Password -FilePath (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx')
	}

} #end Function
