# PSConfigFile
 
## Description
Creates a Config file with Commands, Variables, PSDrives, Aliases\Shortcuts and Default Start locations.
You can then execute this default config when your profile is loaded, or when a specific module is imported, or you can run it manually.

This way you can quickly and easily switch between "environment setups" with these default values
 
## Getting Started
```
- Install-Module -Name PSConfigFile -Verbose
```
OR
```
git clone https://github.com/smitpi/PSConfigFile (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSConfigFile)
```
Then:
```
- Import-Module PSConfigFile -Verbose -Force
 
- Get-Command -Module PSConfigFile
- Get-Help about_PSConfigFile
```
