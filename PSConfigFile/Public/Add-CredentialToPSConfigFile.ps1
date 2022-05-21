
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
 Creates a self signed cert, then uses it to securely save a credentials to the config file. 

#> 


<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credentials to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credentials to the config file.

.EXAMPLE
Add-CredentialToPSConfigFile

#>

<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credentials to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credentials to the config file. 
You can export the cert, and install it on other machines. Then you would be able to decrypt the password on those machines.

.PARAMETER CredName
This name will be used for the variable when invoke command is executed.

.PARAMETER Credentials
Credential object to be saved.

.PARAMETER ExportPFX
Select to export a pfx file, that can be installed on other machines.

.PARAMETER ExportPath
Where to save the pfx file.

.PARAMETER ExportCredentials
The password will be used to export the pfx file.

.PARAMETER RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

.EXAMPLE
$labcred = get-credential
Add-CredentialToPSConfigFile -CredName LabTest -Credentials $labcred

#>
Function Add-CredentialToPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Def', HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(ParameterSetName = 'Def')]
		[string]$CredName,

		[Parameter(ParameterSetName = 'Def')]
		[pscredential]$Credentials,

		[Parameter(ParameterSetName = 'Renew')]
		[switch]$RenewSelfSignedCert = $false,

		[Parameter(ParameterSetName = 'Export')]
		[switch]$ExportPFX = $false,

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(ParameterSetName = 'Export')]
		[System.IO.DirectoryInfo]$ExportPath = 'C:\Temp',

		[Parameter(ParameterSetName = 'Export')]
		[pscredential]$ExportCredentials
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
		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update =@()
        $RenewCreds = @{}
        $Json.PSCreds.PSObject.Properties | Select-Object name, value | Where-Object {$_.value -notlike 'Default'} | ForEach-Object {
			$username = $_.value.split(']-')[0].Replace('[', '')
            $tmpcred = Get-Credential -Credential $username
            $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
		    $PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
		    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
		    $EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
		    if ($PSVersionTable.PSEdition -like 'Desktop') {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)}
		    else {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)}
		    $EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
            $RenewCreds +=  @{
				"$($_.name)" = "[$($username)]-$($EncryptedPwd)"
			}
        }
        $Update = [psobject]@{
			Userdata    = $Json.Userdata
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
    elseif ($ExportPFX) {
            if (-not($ExportCredentials)) {$ExportCredentials = Get-Credential -Message "For exported pfx file"}
            $selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		    if (-not($selfcert)) { Write-Error "Certificate does not exist, nothing to export"}
            else {
			    if (Test-Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')) {Rename-Item -Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"}
			    else {
				    $selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $ExportCredentials.Password -FilePath (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')
			    }
            }
		}
    else {
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
        if (-not($Credentials)) {$Credentials = Get-Credential -Message "Credentials for $($CredName)"}

		$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credentials.Password)
		$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
		[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
		$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
		if ($PSVersionTable.PSEdition -like 'Desktop') {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)}
		else {$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)}
		$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
	
		$Update = @()
		$SetCreds = @{}

		if ($Json.PSCreds.psobject.Properties.name -like 'Default' -and
			$Json.PSCreds.psobject.Properties.value -like 'Default') {
			$SetCreds = @{
				$CredName = "[$($Credentials.UserName)]-$($EncryptedPwd)"
			}
		} else {
			$members = $Json.PSCreds | Get-Member -MemberType NoteProperty
			foreach ($mem in $members) {
				$SetCreds += @{
					$mem.Name = $json.PSCreds.$($mem.Name)
				}
			}
			$SetCreds += @{
				$CredName = "[$($Credentials.UserName)]-$($EncryptedPwd)"
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
    }
} #end Function
