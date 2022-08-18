﻿
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
 Creates a self signed cert, then uses it to securely save a credential to the config file. 

#> 


<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credential to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credential to the config file.

.EXAMPLE
Add-CredentialToPSConfigFile

#>

<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credential to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credential to the config file. 
You can export the cert, and install it on other machines. Then you would be able to decrypt the password on those machines.

.PARAMETER Name
This name will be used for the variable when invoke command is executed.

.PARAMETER Credential
Credential object to be saved.

.EXAMPLE
$labcred = get-credential
Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred

#>
Function Add-CredentialToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Name,
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
			ModifiedAction = "Add Credencial $($Name)"
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}

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

	$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
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
	
	$Update = @()
	[System.Collections.ArrayList]$SetCreds = @()
		
	if ($Json.PSCreds.psobject.Properties.name -like 'Default' -and
		$Json.PSCreds.psobject.Properties.value -like 'Default') {
				
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	} else {
		$Json.PSCreds | ForEach-Object {[void]$SetCreds.Add($_)}
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	}

	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $Json.PSDrive
		PSAlias     = $Json.PSAlias
		PSCreds     = $SetCreds
		PSDefaults  = $Json.PSDefaults
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	try {
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
		Write-Output 'Credential added'
		Write-Output "ConfigFile: $($confile.FullName)"
	} catch { Write-Error "Error: `n $_" }
} #end Function
