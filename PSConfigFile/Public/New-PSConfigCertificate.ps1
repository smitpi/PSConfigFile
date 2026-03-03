
<#PSScriptInfo

.VERSION 0.1.0

.GUID 23d79e04-6c65-4fff-841c-4dc2c6b3576c

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
Created [03/03/2026_09:56] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Creates a new self signed certificate 

#> 


<#
.SYNOPSIS
Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.

.DESCRIPTION
This function generates a new self-signed certificate (or renews an existing one) used to encrypt and decrypt credentials stored in your configuration file. This ensures your sensitive data remains secure and portable across trusted systems. After creating the certificate, all saved credentials are re-encrypted for continued security.

.EXAMPLE
New-PSConfigCertificate
Creates or renews the self-signed certificate for credential encryption and re-encrypts all saved credentials.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Run this if your certificate is expiring or you need to reset credential encryption.
#>
function New-PSConfigCertificate {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigCertificate')]
	[OutputType([System.Object[]])]
	#region Parameter
	param(
	)
	#endregion

	Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}
	$SelfSignedCertParams = @{
		DnsName           = 'PSConfigFileCert'
		KeyDescription    = 'PowerShell Credencial Encryption-Decryption Key'
		Provider          = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
		KeyFriendlyName   = 'PSConfigFileCert'
		FriendlyName      = 'PSConfigFileCert'
		Subject           = 'PSConfigFileCert'
		KeyUsage          = 'DataEncipherment'
		Type              = 'DocumentEncryptionCert'
		HashAlgorithm     = 'sha256'
		CertStoreLocation = 'Cert:\\CurrentUser\\My'
		NotAfter          = (Get-Date).AddMonths(2)
		KeyExportPolicy   = 'Exportable'
	} # end params
	New-SelfSignedCertificate @SelfSignedCertParams | Out-Null

	Update-PSConfigFileCredentials -RenewSavedPasswords 'All'
} #end Function