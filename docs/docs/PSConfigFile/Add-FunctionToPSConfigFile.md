---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-FunctionToPSConfigFile
---

# Add-FunctionToPSConfigFile

## SYNOPSIS

Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Add-FunctionToPSConfigFile [[-FunctionName] <string>] [[-CommandToRun] <string>] [-Force]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to define named PowerShell functions (shortcuts) that execute specific commands or script blocks.
These functions are stored in your configuration file and can be invoked automatically or manually, streamlining repetitive tasks and environment setup.
This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

## EXAMPLES

### EXAMPLE 1

Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "Import-Module .\*.psm1 -Force -Verbose"
Adds a function named 'psml' that imports all PowerShell modules in the current directory with force and verbose options.

### EXAMPLE 2

Add-FunctionToPSConfigFile -FunctionName CleanLogs -CommandToRun "Remove-Item C:\\Logs\\* -Recurse -Force" -Force
Adds a function named 'CleanLogs' to delete all log files, overwriting the config file if it exists.

## PARAMETERS

### -CommandToRun

The PowerShell command(s) or script block to be executed by the function.
Provide as a string.
Example: "Import-Module .\*.psm1 -Force -Verbose"

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

### -FunctionName

The unique name to assign to the custom function.
This name is used to identify and manage the function within the config file.

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

