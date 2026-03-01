
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

