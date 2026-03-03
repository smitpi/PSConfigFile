---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-PSDriveToPSConfigFile
---

# Add-PSDriveToPSConfigFile

## SYNOPSIS

Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.

## SYNTAX

### __AllParameterSets

```
Add-PSDriveToPSConfigFile [[-DriveName] <string>] [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to register a PowerShell drive (PSDrive) in your configuration file.
When the config is invoked, the drive will be automatically available in your session, streamlining access to file systems, registries, or other providers.
The PSDrive must already exist (use New-PSDrive to create it first).

## EXAMPLES

### EXAMPLE 1

New-PSDrive -Name TempDir -PSProvider FileSystem -Root "C:\\Temp"
Add-PSDriveToPSConfigFile -DriveName TempDir
Registers the 'TempDir' PSDrive in the config file for automatic use in future sessions.

### EXAMPLE 2

Add-PSDriveToPSConfigFile -DriveName ProdModules -Force
Adds the 'ProdModules' PSDrive, overwriting the config file if it exists.

## PARAMETERS

### -DriveName

The name of the PSDrive to add.
The drive must already exist in the current session.

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
Use this to ensure custom drives are always available in your PowerShell environment.


## RELATED LINKS

{{ Fill in the related links here }}

