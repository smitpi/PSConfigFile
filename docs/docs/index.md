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
 
## Functions
- [`Add-CommandToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile) -- Adds a command or script block to the config file, to be executed every time the invoke function is called.
- [`Add-CredentialToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile) -- Creates a self signed cert, then uses it to securely save a credential to the config file.
- [`Add-FunctionToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile) -- Creates Shortcuts (Functions) to commands or script blocks
- [`Add-LocationToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile) -- Adds default location to the config file.
- [`Add-PSDefaultParameterToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile) -- Add PSDefaultParameterValues to the config file
- [`Add-PSDriveToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile) -- Add PSDrive to the config file.
- [`Add-VariableToPSConfigFile`](https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile) -- Adds variable to the config file.
- [`Export-PSConfigFilePFX`](https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX) -- Export the PFX file for credentials.
- [`Import-PSConfigFilePFX`](https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX) -- Import the PFX file for credentials
- [`Invoke-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile) -- Executes the config from the json file.
- [`New-PSConfigFile`](https://smitpi.github.io/PSConfigFile/New-PSConfigFile) -- Creates a new config file
- [`Remove-ConfigFromPSConfigFile`](https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile) -- Removes a item from the config file.
- [`Set-PSConfigFileExecution`](https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution) -- Adds functionality to add the execution to your profile.
- [`Show-PSConfigFile`](https://smitpi.github.io/PSConfigFile/Show-PSConfigFile) -- Display what's configured in the config file.
- [`Update-CredentialsInPSConfigFile`](https://smitpi.github.io/PSConfigFile/Update-CredentialsInPSConfigFile) -- Allows you to renew the certificate or saved passwords.
