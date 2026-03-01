
<#PSScriptInfo

.VERSION 0.1.0

.GUID e70b2071-654d-4edc-8fb1-91d6f103c7c6

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
Created [21/05/2022_03:47] Initial Script Creating

.PRIVATEDATA

#>


<#
.SYNOPSIS
Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.

.DESCRIPTION
This function creates a self-signed certificate (if one does not already exist) and uses it to encrypt and store a PowerShell credential object in your configuration file. The certificate can be exported and installed on other machines, allowing you to decrypt and use the credential securely across trusted systems. This is ideal for automating scripts that require credentials without exposing sensitive information in plain text.

.PARAMETER Name
The variable name to assign to the credential in the config file. This name is used to reference the credential when invoking commands from the config.

.PARAMETER Credential
The PowerShell credential object to be securely stored. Use Get-Credential to create this object.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
$labcred = Get-Credential
Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred
Prompts for credentials and saves them securely in the config file under the name 'LabTest'.

.EXAMPLE
Add-CredentialToPSConfigFile -Name AdminUser -Credential (Get-Credential) -Force
Saves a credential named 'AdminUser', overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Credentials are encrypted using a self-signed certificate for security and portability.
#>
function Add-CredentialToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	param(
		[string]$Name,
		[pscredential]$Credential,
		[switch]$Force
	)

 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$XMLData = Import-Clixml -Path $confile.FullName
	$userdata = [PSCustomObject]@{
		Owner             = $XMLData.Userdata.Owner
		CreatedOn         = $XMLData.Userdata.CreatedOn
		PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
		Path              = $XMLData.Userdata.Path
		Hostname          = $XMLData.Userdata.Hostname
		PSEdition         = $XMLData.Userdata.PSEdition
		OS                = $XMLData.Userdata.OS
		BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = [datetime](Get-Date)
			ModifiedAction = "Added Credencial: $($Name)"
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
		Write-Warning -Message 'Password is saved for Windows PowerShell, rerun command in PowerShell Core to save it in that edition as well.'
		$Edition = 'PSDesktop'
		$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)
	} else {
		Write-Warning -Message 'Password is saved for PowerShell Core, rerun command in Windows PowerShell to save it in that edition as well.'
		$Edition = 'PSCore'
		$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
	}
	$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
	
	$Update = @()
	[System.Collections.ArrayList]$SetCreds = @()
		
	if ([string]::IsNullOrEmpty($XMLData.PSCreds)) {
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	} else {
		$XMLData.PSCreds | ForEach-Object {[void]$SetCreds.Add($_)}
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	}

	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $XMLData.PSDrive
		PSFunction  = $XMLData.PSFunction
		PSCreds     = ($SetCreds | Where-Object {$_ -notlike $null} | Sort-Object -Property Name)
		PSDefaults  = $XMLData.PSDefaults
		SetLocation = $XMLData.SetLocation
		SetVariable = $XMLData.SetVariable
		Execute     = $XMLData.Execute
	}
	try {
		if ($force) {
			Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
			Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
		} else {
			Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
			Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
		}
		$Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
		Write-Host 'Credential Added: ' -ForegroundColor Green -NoNewline
		Write-Host "$($Name)" -ForegroundColor Yellow
		Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
	} catch { Write-Error "Error: `n $_" }
} #end Function
