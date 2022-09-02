
<#PSScriptInfo

.VERSION 0.1.0

.GUID e7d4d90b-fd4b-433d-bd88-de782bbd6692

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
Created [01/09/2022_18:30] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Update the certificate or credentials from the config file 

#> 


<#
.SYNOPSIS
Allows you to renew the certificate or saved passwords.

.DESCRIPTION
Allows you to renew the certificate or saved passwords.

.PARAMETER RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

.PARAMETER RenewSavedPasswords
Re-encrypts the passwords for the current PS Edition. Run it in PS core and desktop to save both version.

.PARAMETER Force
Will delete the config file before saving the new one. If false, then the config file will be renamed.

.EXAMPLE
Update-CredentialsInPSConfigFile -RenewSavedPasswords All

#>
Function Update-CredentialsInPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Update-CredentialsInPSConfigFile')]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
	PARAM(
		[switch]$RenewSelfSignedCert,
		[string[]]$RenewSavedPasswords = 'All',
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
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = (Get-Date -Format u)
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = 'Modified Credentials'
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}

	function RedoPass {
		PARAM([string[]]$RenewSavedPasswords)

		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update = @()
		[System.Collections.generic.List[PSObject]]$CredsObject = @()
		[System.Collections.generic.List[PSObject]]$RenewCredsObject = @()
		[System.Collections.generic.List[PSObject]]$ThisEdition = @()
		[System.Collections.generic.List[PSObject]]$OtherEdition = @()
		$AllCreds = $XMLData.PSCreds | Sort-Object -Property Name -Unique 

		if ($RenewSavedPasswords -like 'All') {
			$AllCreds | ForEach-Object {$RenewCredsObject.add($_)}
		} else {
			$XMLData.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"} | Sort-Object -Property Name -Unique | ForEach-Object {$ThisEdition.add($_)}
			$XMLData.PSCreds | Where-Object {$_.Edition -notlike "*$($PSVersionTable.PSEdition)*"} | Sort-Object -Property Name -Unique | ForEach-Object {$OtherEdition.add($_)}
			$OtherEdition | Where-Object {$_.name -notin $ThisEdition.Name} | Sort-Object -Property Name -Unique | ForEach-Object {$RenewCredsObject.add($_)}
			
			foreach ($AddCred in $RenewSavedPasswords) {
				$AllCreds | Where-Object {$_.name -like $AddCred} | ForEach-Object {$RenewCredsObject.add($_)}
				$ThisEdition  | Where-Object {$_.name -like $AddCred} | ForEach-Object {$ThisEdition.Remove($_)}
			}
			$ThisEdition | ForEach-Object {$CredsObject.Add($_)}
			$OtherEdition | ForEach-Object {$CredsObject.Add($_)}
			$RenewCredsObject =  $RenewCredsObject | Sort-Object -Property name -Unique
		}

		foreach ($cred in $RenewCredsObject) {
			$tmpcred = Get-Credential -UserName $cred.UserName -Message 'Renew Password'
			$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
			$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
			$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
			if ($PSVersionTable.PSEdition -like 'Desktop') {
				Write-Warning -Message 'Password is saved for Windows PowerShell, rerun command in PowerShell Core to save it in that edition as well.'
				$Edition = 'PSDesktop'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)
			} else {
				Write-Warning -Message 'Password is saved for PowerShell Core, rerun command in Windows PowerShell Core to save it in that edition as well.'
				$Edition = 'PSCore'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
			}
			$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
			$CredsObject.Add([PSCustomObject]@{
					Name         = $cred.name
					Edition      = $Edition
					UserName     = $cred.UserName
					EncryptedPwd = $EncryptedPwd
				})
		}

		$Update = [psobject]@{
			Userdata    = $Userdata
			PSDrive     = $XMLData.PSDrive
			PSFunction  = $XMLData.PSFunction
			PSCreds     = ($CredsObject | Where-Object {$_ -notlike $null} | Sort-Object -Property Name)
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
			Write-Host 'Credentials Updated' -ForegroundColor Green
			Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
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
		RedoPass -RenewSavedPasswords All
	} 
	if (-not([string]::IsNullOrEmpty($RenewSavedPasswords))) {RedoPass -RenewSavedPasswords $RenewSavedPasswords}

} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$var = @('All')
	$var += Get-Variable | Where-Object {$_.Name -like "$wordToComplete*" -and $_.value -like 'System.Management.Automation.PSCredential'} | ForEach-Object {"$($_.name)"}
	$var
}
Register-ArgumentCompleter -CommandName Update-CredentialsInPSConfigFile -ParameterName RenewSavedPasswords -ScriptBlock $scriptBlock
