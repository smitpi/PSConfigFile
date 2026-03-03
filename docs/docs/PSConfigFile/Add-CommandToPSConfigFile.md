---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-CommandToPSConfigFile
---

# Add-CommandToPSConfigFile

## SYNOPSIS

Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.

## SYNTAX

### __AllParameterSets

```
Add-CommandToPSConfigFile [[-ScriptBlockName] <string>] [[-ScriptBlock] <string>] [-Force]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to store custom commands or script blocks in your configuration file.
These commands will be executed every time the config file is invoked using Invoke-PSConfigFile.
This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

## EXAMPLES

### EXAMPLE 1

Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\\"
Adds a script block named 'DriveC' that lists the contents of the C drive every time the config is invoked.

### EXAMPLE 2

Add-CommandToPSConfigFile -ScriptBlockName Startup -ScriptBlock "Write-Host 'Welcome!'" -Force
Adds a script block named 'Startup' that displays a welcome message, overwriting the config file if it exists.

## PARAMETERS

### -Force

If specified, the config file will be deleted before saving the new one.
If not specified and a config file exists, it will be renamed as a backup before saving the new version.

```yaml
Type: SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptBlock

The PowerShell command(s) or script block to be executed.
Provide as a string.
Example: "Get-ChildItem C:\\Logs | Out-File C:\\log.txt"

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptBlockName

The unique name to assign to the script block.
This name is used to identify and manage the command within the config file.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.


## RELATED LINKS

{{ Fill in the related links here }}

