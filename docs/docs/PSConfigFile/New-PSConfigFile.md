---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/New-PSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: New-PSConfigFile
---

# New-PSConfigFile

## SYNOPSIS

Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.

## SYNTAX

### __AllParameterSets

```
New-PSConfigFile [-ConfigDir] <DirectoryInfo> [[-BackupsToKeep] <int>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function initializes a new configuration file in the specified directory, capturing your environment's settings, drives, functions, credentials, variables, and more.
If a config file already exists in the folder, it will be renamed as a backup before creating the new one.
You can specify how many backup copies to keep when the config changes.

## EXAMPLES

### EXAMPLE 1

New-PSConfigFile -ConfigDir C:\\Temp\\config -BackupsToKeep 3
Creates a new config file in C:\Temp\config and keeps up to 3 backup copies.

### EXAMPLE 2

New-PSConfigFile -ConfigDir .
Creates a new config file in the current directory with the default number of backups.

## PARAMETERS

### -BackupsToKeep

The number of backup copies to keep when the config file is changed.
Older backups beyond this number will be deleted automatically.

```yaml
Type: Int32
DefaultValue: 3
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

### -ConfigDir

The directory where the new config file will be created.
The directory will be created if it does not exist.

```yaml
Type: DirectoryInfo
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

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
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
Use this to start managing your PowerShell environment with a portable, versioned config file.


## RELATED LINKS

{{ Fill in the related links here }}

