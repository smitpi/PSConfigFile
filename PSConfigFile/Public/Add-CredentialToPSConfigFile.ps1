
<#PSScriptInfo

.VERSION 0.1.0

.GUID e70b2071-654d-4edc-8fb1-91d6f103c7c6

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
Created [21/05/2022_03:47] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Creates a self signed cert, then uses it to securely save a credencials to the config file. 

#> 


<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credencials to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credencials to the config file.

.EXAMPLE
Add-CredentialToPSConfigFile

#>
Function Add-CredentialToPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Def', HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = 'Def')]
		[Parameter(ParameterSetName = 'Export')]
		[pscredential]$Credentials,

		[Parameter(ParameterSetName = 'Export')]
		[switch]$ExportPFX = $false,

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(ParameterSetName = 'Export')]
		[System.IO.DirectoryInfo]$ExportPath = 'C:\Temp',

		[Parameter(ParameterSetName = 'Export')]
		[pscredential]$ExportCredentials,

		[Parameter(ParameterSetName = 'Def')]
		[Parameter(ParameterSetName = 'Export')]
		[switch]$RenewSelfSignedCert = $false
	)

 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms$
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json

	if ($RenewSelfSignedCert) { Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}}

	$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	if (-not($selfcert)) {
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
		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	}

	if ($ExportPFX) {
		if (Test-Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')) {Rename-Item -Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format -Format yyyy.MM.dd-HH.mm).pfx"}
		else {
			$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $ExportCredentials.Password -FilePath (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')
		}
	}
	$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credentials.Password)
	$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
	[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
	$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
    if ($PSVersionTable.PSEdition -like "Desktop") {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)}
    else {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)}
	$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
	
	$Update = @()
	$SetCreds = @{}

	if ($Json.PSCreds.psobject.Properties.name -like 'Default' -and
		$Json.PSCreds.psobject.Properties.value -like 'Default') {
		$SetCreds = @{
			$Credentials.UserName = $EncryptedPwd
		}
	} else {
		$members = $Json.PSCreds | Get-Member -MemberType NoteProperty
		foreach ($mem in $members) {
			$SetCreds += @{
				$mem.Name = $json.PSCreds.$($mem.Name)
			}
		}
		$SetCreds += @{
			$Credentials.UserName = $EncryptedPwd
		}
	}

	$Update = [psobject]@{
		Userdata    = $Json.Userdata
		PSDrive     = $Json.PSDrive
		PSAlias     = $Json.PSAlias
		PSCreds     = $SetCreds
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	try {
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
		Write-Output 'Credentials added'
		Write-Output "ConfigFile: $($confile.FullName)"
	} catch { Write-Error "Error: `n $_" }

} #end Function
