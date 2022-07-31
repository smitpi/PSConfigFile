
<#PSScriptInfo

.VERSION 0.1.0

.GUID 30a6ec8d-630b-42d1-a926-32a3541617d9

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
Created [28/07/2022_20:29] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#
.SYNOPSIS
Allows you to renew the certificate,saved passwords and export/import pfx file

.DESCRIPTION
Allows you to renew the certificate,saved passwords and export/import pfx file

.PARAMETER RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

.PARAMETER RenewSavedPasswords
Re-encrypts the passwords for the current PS Edition. Run it in PS core and desktop to save both version.

.PARAMETER ExportPFX
Select to export a pfx file, that can be installed on other machines.

.PARAMETER ImportPFX
Import the previously exported PFX file.

.PARAMETER PFXFilePath
path to the .pfx file.

.PARAMETER ExportPath
Where to export the .pfx file.

.PARAMETER Credential
This password will be used to import or export the .pfx file.

.EXAMPLE
Update-CredentialsInPSConfigFile -ExportPFX -ExportPath C:\Temp\ 

#>
Function Update-CredentialsInPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Renew', HelpURI = 'https://smitpi.github.io/PSConfigFile/Update-CredentialsInPSConfigFile')]
	PARAM(
		[Parameter(ParameterSetName = 'Renew')]
		[switch]$RenewSelfSignedCert,

		[Parameter(ParameterSetName = 'Renew')]
		[switch]$RenewSavedPasswords,

		[Parameter(ParameterSetName = 'Export')]
		[switch]$ExportPFX,

		[Parameter(ParameterSetName = 'Import')]
		[switch]$ImportPFX,

		[ValidateScript( { if ((Get-Item $_).Extension -like '.pfx') { $true }
				else {throw 'Not a valid .pfx file'}	
			})]
		[Parameter(ParameterSetName = 'Import')]
		[System.IO.FileInfo]$PFXFilePath = "$($env:temp)",

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(ParameterSetName = 'Export')]
		[System.IO.DirectoryInfo]$ExportPath = "$($env:temp)",

		[Parameter(ParameterSetName = 'Import')]
		[Parameter(ParameterSetName = 'Export')]
		[pscredential]$Credential
		
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
			ModifiedAction = 'Modified Credentials'
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}

	function RedoPass {
		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update = @()
		[System.Collections.ArrayList]$RenewCreds = @()
        
		foreach ($OtherCred in ($Json.PSCreds | Where-Object {$_.Edition -notlike "*$($PSVersionTable.PSEdition)*"})) {
			[void]$RenewCreds.Add($OtherCred)
		}
        
		$UniqueCreds = $Json.PSCreds | Sort-Object -Property Name -Unique
        
		foreach ($cred in $UniqueCreds) {
			$tmpcred = Get-Credential -UserName $cred.UserName -Message 'Renew Password'
			$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
			$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
			$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
			if ($PSVersionTable.PSEdition -like 'Desktop') {
				$Edition = 'PSDesktop'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)
			} else {
				$Edition = 'PSCore'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
			}
			$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
			[void]$RenewCreds.Add([PSCustomObject]@{
					Name         = $cred.name
					Edition      = $Edition
					UserName     = $cred.UserName
					EncryptedPwd = $EncryptedPwd
				})
		}
		$Update = [psobject]@{
			Userdata    = $Userdata
			PSDrive     = $Json.PSDrive
			PSAlias     = $Json.PSAlias
			PSCreds     = $RenewCreds
			SetLocation = $Json.SetLocation
			SetVariable = $Json.SetVariable
			Execute     = $Json.Execute
		}
		try {
			$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
			Write-Output 'Credentials Updated'
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }
	}

	if ($RenewSelfSignedCert) { 
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
		RedoPass
	} 
	if ($RenewSavedPasswords) {RedoPass}
	if ($ExportPFX) {
		if ([string]::IsNullOrEmpty($Credential)) {$Credential = Get-Credential -UserName PFXExport -Message 'For the exported pfx file'}
		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		if (-not($selfcert)) { Write-Error 'Certificate does not exist, nothing to export'}
		else {
			if (Test-Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')) {
				Rename-Item -Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"
			}
			$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $Credential.Password -FilePath (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')
		}
	} 
	if ($ImportPFX) {
		if ([string]::IsNullOrEmpty($Credential)) {$Credential = Get-Credential -UserName PFXImport -Message 'For the imported pfx file'}
		Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}
		Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $PFXFilePath -Password $Credential.Password 
	}
} #end Function
