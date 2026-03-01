# PSConfigFile
 
## Description
Creates a Config file with Variables, PSDrives, Credentials, Shortcuts(Functions), PSDefaultParameters and a Starting location. You can then execute this config when your profile is loaded, or you can run it manually at any time. And all of the variables, psdrives credentials ext. are then available in your session. This way you can quickly and easily switch between "environment setups"
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSConfigFile)
```
Install-Module -Name PSConfigFile -Verbose
```
- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/PSConfigFile)
```
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSConfigFile)
git clone --depth 1 https://github.com/smitpi/PSConfigFile $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```
- Then import the module into your session
```
Import-Module PSConfigFile -Verbose -Force
```
- or run these commands for more help and details.
```
Get-Command -Module PSConfigFile
Get-Help about_PSConfigFile
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/PSConfigFile)
 
## PS Controller Scripts
- .git
- .github
- .vscode
- docs
- Output
- PSConfigFile
- removed
- .whitesource
- instructions.md
- LICENSE
- ScriptInfo.zip
 
## Functions
- [`Add-FunctionToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile) -- Adds a custom function (shortcut) to the PSConfigFile configuration for quick command or script execution.
- [`Add-LocationToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile) -- Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.
- [`Add-PSDriveToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile) -- Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.
- [`Add-VariableToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile) -- Adds one or more existing variables to the PSConfigFile configuration for automatic session import.
- [`Import-PSConfigFilePFX`](https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX) -- 
Import-PSConfigFilePFX [-Path] <FileInfo> [[-Credential] <pscredential>] [-Force] [<CommonParameters>]

- [`Invoke-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile) -- Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.
- [`New-PSConfigCertificate`](https://smitpi.github.io/PSConfigFile/New-PSConfigCertificate) -- Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.
- [`New-PSConfigFile`](https://smitpi.github.io/PSConfigFile/New-PSConfigFile) -- Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.
- [`Remove-ConfigFromPSConfigFile`](https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile) -- Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.
- [`Set-PSConfigFileExecution`](https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution) -- 
Set-PSConfigFileExecution [-PSProfile <string>] [-DisplayOutput] [-WhatIf] [-Confirm] [<CommonParameters>]

- [`Show-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Show-PSConfigFile) -- 
Show-PSConfigFile [[-OtherConfigFile] <FileInfo>] [-ShowLastInvokeOutput] [<CommonParameters>]

- [`Update-PSConfigFileCredentials`](https://smitpi.github.io/PSConfigFile/Update-PSConfigFileCredentials) -- Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.
