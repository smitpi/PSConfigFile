
<#PSScriptInfo

.VERSION 0.1.0

.GUID c81fb6d6-76b7-4a9e-9bde-83565c6907a5

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
Created [18/08/2022_09:38] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Import the PFX file for credentials 

#> 


<#
.SYNOPSIS
Import the PFX file for credentials

.DESCRIPTION
Import the PFX file for credentials

.PARAMETER Path
Path to the PFX file.

.PARAMETER Credential
Credential used to create the pfx file.

.PARAMETER Force
Will override existing certificates.

.EXAMPLE
$creds = Get-Credential
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds

#>
Function Import-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	PARAM(
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
