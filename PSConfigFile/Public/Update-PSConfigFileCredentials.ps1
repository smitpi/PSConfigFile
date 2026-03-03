
<#PSScriptInfo

.VERSION 1.1.5

.GUID e7d4d90b-fd4b-433d-bd88-de782bbd6692

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
Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.

.DESCRIPTION
This function allows you to renew the self-signed certificate used for credential encryption, and to re-encrypt or update saved credentials for your PowerShell environment. This is useful when certificates expire, passwords change, or you need to ensure compatibility across PowerShell editions (Core/Desktop). You can renew all credentials or select specific ones by name.

.PARAMETER RenewSavedPasswords
Specifies which saved credentials to renew. Use 'All' to renew all credentials, or provide an array of credential names. Run in both PowerShell Core and Desktop to ensure compatibility.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Update-PSConfigFileCredentials -RenewSavedPasswords All
Prompts to renew all saved credentials in the config file.

.EXAMPLE
Update-PSConfigFileCredentials -RenewSavedPasswords AdminUser,LabTest
Renews only the 'AdminUser' and 'LabTest' credentials.

#>
function Update-PSConfigFileCredentials {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Update-PSConfigFileCredentials')]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
	param(
		[string[]]$RenewSavedPasswords = 'All',
		[switch]$Force
	)
	##TODO Add parameters prefetch for userids.
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
			ModifiedAction = 'Modified Credentials'
		}
	}

	function RedoPass {
		param([string[]]$RenewSavedPasswords)

		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update = @()
		[System.Collections.generic.List[PSObject]]$CredsObject = @()
		[System.Collections.generic.List[PSObject]]$RenewCredsObject = @()
		$AllCreds = $XMLData.PSCreds | Sort-Object -Property Name -Unique 

		if ($RenewSavedPasswords -like 'All') {
			$AllCreds | ForEach-Object { $RenewCredsObject.Add($_) }
		} else {
			foreach ($credName in $RenewSavedPasswords) {
				$AllCreds | Where-Object { $_.Name -like $credName } | ForEach-Object { $RenewCredsObject.Add($_) }
			}
			$RenewCredsObject = $RenewCredsObject | Sort-Object -Property Name -Unique
		}

		foreach ($cred in $RenewCredsObject) {
			$tmpcred = Get-Credential -UserName $cred.UserName -Message 'Renew Password'
			$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
			$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
			$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
			if ($PSVersionTable.PSEdition -like 'Desktop') {
				Write-Error 'Credentials is only a feature of Powershell core.'
				return
			} else {
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
			if ($Force) {
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

	if (-not([string]::IsNullOrEmpty($RenewSavedPasswords))) {RedoPass -RenewSavedPasswords $RenewSavedPasswords}

} #end Function

$PSCredential = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$confile = Get-Item $PSConfigFile
	$XMLData = Import-Clixml -Path $confile.FullName
	$var = @('All')
	$var += $XMLData.PSCreds | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { "$($_.name)" }
	$var
}
Register-ArgumentCompleter -CommandName Update-PSConfigFileCredentials -ParameterName RenewSavedPasswords -ScriptBlock $PSCredential