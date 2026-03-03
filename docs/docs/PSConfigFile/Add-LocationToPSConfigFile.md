---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-LocationToPSConfigFile
---

# Add-LocationToPSConfigFile

## SYNOPSIS

Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Add-LocationToPSConfigFile [-LocationType] <string> [-Path] <string> [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to specify a default working location for your PowerShell session, either as a folder path or a PSDrive.
When the config file is invoked using Invoke-PSConfigFile, your session will automatically change to this location.
This is useful for streamlining your workflow and ensuring you always start in the correct directory or drive.

## EXAMPLES

### EXAMPLE 1

Add-LocationToPSConfigFile -LocationType PSDrive -Path temp
Sets the default location to the 'temp' PSDrive when the config is invoked.

### EXAMPLE 2

Add-LocationToPSConfigFile -LocationType Folder -Path c:\temp
Sets the default location to the 'c:\temp' folder when the config is invoked.

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

### -LocationType

Specifies the type of location to add.
Accepts 'PSDrive' for a PowerShell drive or 'Folder' for a filesystem path.

```yaml
Type: String
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

### -Path

The path to the folder or the name of the PSDrive to set as the default location.
Must exist as a valid path or drive.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
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
Use this to ensure your PowerShell session always starts in the correct directory or drive.


## RELATED LINKS

{{ Fill in the related links here }}

