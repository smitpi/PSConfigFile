# PSConfigFile
 
## Description
Creates a Config file with Commands, Variables, PSDrives, Credentials, Aliases\Shortcuts and a Default Starting location. You can then execute this config file when your profile is loaded, or when a specific module is imported, or you can run it manually. This way you can quickly and easily switch between "environment setups" with these default values
 
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
 
## Functions
- [`Add-AliasToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-AliasToPSConfigFile) -- Creates Shortcuts (Aliases) to commands or script blocks
- [`Add-CommandToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-CommandToPSConfigFile) -- Adds a command or script block to the config file, to be executed every time the invoke function is called.
- [`Add-CredentialToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-CredentialToPSConfigFile) -- Creates a self signed cert, then uses it to securely save a credentials to the config file.
- [`Add-LocationToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-LocationToPSConfigFile) -- Adds default location to the config file.
- [`Add-PSDriveToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-PSDriveToPSConfigFile) -- Add PSDrive to the config file.
- [`Add-VariableToPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Add-VariableToPSConfigFile) -- Adds variable to the config file.
- [`gitpull`](https://smitpi.github.io/PSConfigFile/#gitpull) -- 
gitpull 

- [`gitpush`](https://smitpi.github.io/PSConfigFile/#gitpush) -- 
gitpush 

- [`importmod`](https://smitpi.github.io/PSConfigFile/#importmod) -- 
importmod 

- [`Invoke-PSConfigFile`](https://smitpi.github.io/PSConfigFile/#Invoke-PSConfigFile) -- Executes the config from the json file.
- [`New-PSConfigFile`](https://smitpi.github.io/PSConfigFile/#New-PSConfigFile) -- Creates a new config file
- [`Remove-ConfigFromPSConfigFile`](https://smitpi.github.io/PSConfigFile/#Remove-ConfigFromPSConfigFile) -- Will display existing config with the option to remove it from the config file
- [`set-location-AllUsersModules`](https://smitpi.github.io/PSConfigFile/#set-location-AllUsersModules) -- 
set-location-AllUsersModules 

- [`set-location-labscripts`](https://smitpi.github.io/PSConfigFile/#set-location-labscripts) -- 
set-location-labscripts 

- [`set-location-prodmodules`](https://smitpi.github.io/PSConfigFile/#set-location-prodmodules) -- 
set-location-prodmodules 

- [`set-location-psmodules`](https://smitpi.github.io/PSConfigFile/#set-location-psmodules) -- 
set-location-psmodules 

- [`Set-PSConfigFileExecution`](https://smitpi.github.io/PSConfigFile/#Set-PSConfigFileExecution) -- Adds functionality to add the execution to your profile or a PowerShell module
- [`Show-PSConfigFile`](https://smitpi.github.io/PSConfigFile/#Show-PSConfigFile) -- Display what's configured in the config file.
