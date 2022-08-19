# PSConfigFile
 
## Description
Creates a Config file with Variables, PSDrives, Credentials, Shortcuts(Functions), PSDefaultParameters and a Starting location. You can then execute this config when your profile is loaded, or you can run it manually at any time. And all of these variables, psdrives credentials ext. are then available in your session. This way you can quickly and easily switch between "environment setups"
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSConfigFile)
```
Install-Module -Name PSConfigFile -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/PSConfigFile)
```
git clone https://github.com/smitpi/PSConfigFile (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSConfigFile)
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
