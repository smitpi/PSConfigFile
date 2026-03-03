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
