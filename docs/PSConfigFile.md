---
Module Name: PSConfigFile
Module Guid: d1fff6c2-e0c4-49ba-8632-e0137d78151c
Download Help Link: 
Help Version: 0.1.16
Locale: en-US
---

# PSConfigFile Module
## Description
Creates a Config file with Commands,Variables,PSDrives and locations, that can be imported into a session, and the objects are recreated \ executed

## PSConfigFile Cmdlets
### [Add-CommandToPSConfigFile](Add-CommandToPSConfigFile.md)
Adds a command or script block to the config file, to be executed every time the invoke function is called.

### [Add-LocationToPSConfigFile](Add-LocationToPSConfigFile.md)
Adds default location to the config file.

### [Add-PSDriveToPSConfigFile](Add-PSDriveToPSConfigFile.md)
Add PSDrive to the config file.

### [Add-VariableToPSConfigFile](Add-VariableToPSConfigFile.md)
Adds variable to the config file.

### [Invoke-PSConfigFile](Invoke-PSConfigFile.md)
Executes the config from the json file.

### [New-PSConfigFile](New-PSConfigFile.md)
Creates a new config file

### [Update-PSConfigFile](Update-PSConfigFile.md)
Adds functionality to add the execution to your profile or a PowerShell module

