# PSConfigFile

## Description

PSConfigFile is an extension to your PowerShell profile that enables advanced, portable, and modular environment management. 



It creates a configuration file containing Variables, PSDrives, Credentials, Shortcuts (Functions), PSDefaultParameters, and a Starting Location. 



You can execute this config automatically when your profile loads, or manually at any time, making all your environment settings instantly available in your session. Effortlessly switch between different environment setups, share configurations across systems, and keep your PowerShell experience consistent and efficient.

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
- instructions.md
- LICENSE
- README.md
 
## Functions
- [`Add-CommandToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile) -- Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.
- [`Add-CredentialToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile) -- Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.
- [`Add-FunctionToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile) -- Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.
- [`Add-LocationToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile) -- Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.
- [`Add-PSDefaultParameterToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile) -- Adds a default parameter value for a function to the PSConfigFile configuration.
- [`Add-PSDriveToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile) -- Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.
- [`Add-VariableToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile) -- Adds one or more existing variables to the PSConfigFile configuration for automatic session import.
- [`Export-PSConfigFilePFX`](https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX) -- Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.
- [`Import-PSConfigFilePFX`](https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX) -- Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.
- [`Invoke-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile) -- Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.
- [`New-PSConfigCertificate`](https://smitpi.github.io/PSConfigFile/New-PSConfigCertificate) -- Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.
- [`New-PSConfigFile`](https://smitpi.github.io/PSConfigFile/New-PSConfigFile) -- Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.
- [`Remove-ConfigFromPSConfigFile`](https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile) -- Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.
- [`Set-PSConfigFileExecution`](https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution) -- Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.
- [`Show-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Show-PSConfigFile) -- Display what's configured in the config file.
- [`Update-PSConfigFileCredentials`](https://smitpi.github.io/PSConfigFile/Update-PSConfigFileCredentials) -- Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.
