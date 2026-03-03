---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Invoke-PSConfigFile
---

# Invoke-PSConfigFile

## SYNOPSIS

Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.

## SYNTAX

### __AllParameterSets

```
Invoke-PSConfigFile [-ConfigFile] <FileInfo> [-DisplayOutput] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to load a PSConfigFile XML configuration file and apply all stored settings to your current session.
This includes setting variables, creating PSDrives, defining functions, importing credentials, applying default parameters, setting the working directory, and executing startup commands.
Use this to quickly restore your preferred environment or automate session setup across systems.

## EXAMPLES

### EXAMPLE 1

Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSConfigFile.xml
Loads and applies all settings from the specified config file.

### EXAMPLE 2

Invoke-PSConfigFile -ConfigFile .\PSConfigFile.xml -DisplayOutput
Runs the config file and displays detailed output for each step.

## PARAMETERS

### -ConfigFile

The path to the configuration XML file created by New-PSConfigFile.
Must have a .xml extension.

```yaml
Type: FileInfo
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DisplayOutput

If specified, displays detailed output of each configuration step.
Otherwise, only completion status is shown.
Use Show-PSConfigFile to display the last execution output.

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
Use this to automate and standardize your PowerShell environment setup.


## RELATED LINKS

{{ Fill in the related links here }}

