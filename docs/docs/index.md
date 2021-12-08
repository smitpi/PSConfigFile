## Description
Creates a Config file with Commands, Variables, PSDrives, Aliases\Shortcuts and Default Start locations.
You can then execute this default config when your profile is loaded, or when a specific module is imported, or you can run it manually.

This way you can quickly and easily switch between "environment setups" with these default values

## Getting Started
- `Install-Module -Name PSConfigFile -Verbose`
- `Import-Module PSConfigFile -Verbose -Force`
- `Get-Command -Module PSConfigFile`

## Functions
- [Add-AliasToPSConfigFile](Add-AliasToPSConfigFile.md) -- Creates Shortcuts (Aliases) to commands or script blocks
- [Add-CommandToPSConfigFile](Add-CommandToPSConfigFile.md) -- Adds a command or script block to the config file, to be executed every time the invoke function is called.
- [Add-LocationToPSConfigFile](Add-LocationToPSConfigFile.md) -- Adds default location to the config file.
- [Add-PSDriveToPSConfigFile](Add-PSDriveToPSConfigFile.md) -- Add PSDrive to the config file.
- [Add-VariableToPSConfigFile](Add-VariableToPSConfigFile.md) -- Adds variable to the config file.
- [Invoke-PSConfigFile](Invoke-PSConfigFile.md) -- Executes the config from the json file.
- [New-PSConfigFile](New-PSConfigFile.md) -- Creates a new config file
- [Set-PSConfigFileExecution](Set-PSConfigFileExecution.md) -- Adds functionality to add the execution to your profile or a PowerShell module
- [Show-PSConfigFile](Show-PSConfigFile.md) -- Display what's configured in the config file.


