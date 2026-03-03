---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-VariableToPSConfigFile
---

# Add-VariableToPSConfigFile

## SYNOPSIS

Adds one or more existing variables to the PSConfigFile configuration for automatic session import.

## SYNTAX

### __AllParameterSets

```
Add-VariableToPSConfigFile [[-VariableNames] <string[]>] [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function allows you to store the values of existing variables in your configuration file.
When the config is invoked, these variables will be automatically recreated in your session, making it easy to persist tokens, paths, or other important values across PowerShell sessions.
SecureString and PSCredential types are not allowed for security reasons.

## EXAMPLES

### EXAMPLE 1

Add-VariableToPSConfigFile -VariableNames AzureToken
Adds the 'AzureToken' variable to the config file for automatic import in future sessions.

### EXAMPLE 2

Add-VariableToPSConfigFile -VariableNames Path1,Path2 -Force
Adds both 'Path1' and 'Path2' variables, overwriting the config file if it exists.

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

### -VariableNames

The name(s) of the variable(s) to add.
Each variable must already exist in the current session.

```yaml
Type: String[]
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
Use this to persist important variables between PowerShell sessions.


## RELATED LINKS

{{ Fill in the related links here }}

