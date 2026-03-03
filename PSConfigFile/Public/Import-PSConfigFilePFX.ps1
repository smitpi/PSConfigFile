
<#PSScriptInfo

.VERSION 1.1.5

.GUID c81fb6d6-76b7-4a9e-9bde-83565c6907a5

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [18/08/2022_09:38] Initial Script Creating

.PRIVATEDATA

#> 




<# 

.DESCRIPTION 
 Import the PFX file for credentials 

#> 

<#
.SYNOPSIS
Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.

.DESCRIPTION
Use this function to import a self-signed certificate (in PFX format) that is used to decrypt credentials in your PSConfigFile configuration. This is useful when moving your configuration to a new system or restoring access to encrypted credentials. You must provide the credential used to protect the PFX file. Optionally, you can force the import to override existing certificates.

.PARAMETER Path
The path to the PFX file to import. Must be a valid .pfx file.

.PARAMETER Credential
The credential (username and password) that was used to protect the PFX file. Use Get-Credential to create this object.

.PARAMETER Force
If specified, will override any existing certificates with the same name.

.EXAMPLE
$creds = Get-Credential
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds
Imports the certificate from C:\temp, using the provided credentials for decryption.

.EXAMPLE
Import-PSConfigFilePFX -Path .\PSConfigFileCert.pfx -Credential (Get-Credential) -Force
Imports and overwrites any existing certificate with the same name.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to restore credential decryption capability on new or rebuilt systems.
#>
function Import-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	param(
		[Parameter(Mandatory)]
		[ValidateScript( { if ((Get-Item $_).Extension -like '.pfx') { $true }
				else {throw 'Not a valid .pfx file'}	
			})]
		[System.IO.FileInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName InportPFX -Message 'For the imported pfx file'),
		[switch]$Force = $false
	)
	$CheckExisting = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue 
	if (-not([string]::IsNullOrEmpty($CheckExisting))) {
		if ($Force) {$CheckExisting | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}}
		else {
			Write-Warning 'Certificate already exists, use -Force to override the existing certificate'
			return
		}
	}
	Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $Path -Password $Credential.Password 
} #end Function
