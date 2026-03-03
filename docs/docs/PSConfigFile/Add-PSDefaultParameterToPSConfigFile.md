---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-PSDefaultParameterToPSConfigFile
---

# Add-PSDefaultParameterToPSConfigFile

## SYNOPSIS

Adds a default parameter value for a function to the PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Add-PSDefaultParameterToPSConfigFile [-Function] <string> [-Parameter] <string> [-Value] <string>
 [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function allows you to specify default parameter values for any PowerShell function.
These defaults are stored in your configuration file and will be automatically applied in your session, saving you from repeatedly specifying common parameters.
Wildcards can be used to apply defaults to multiple functions or parameters.

## EXAMPLES

### EXAMPLE 1

Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\\temp\\PSLauncherConfig.json
Sets a default value for the 'PSLauncherConfigFile' parameter of the 'Start-PSLauncher' function.

### EXAMPLE 2

Add-PSDefaultParameterToPSConfigFile -Function *-Item -Parameter Path -Value C:\\Data -Force
Sets a default 'Path' for all functions ending with '-Item', overwriting the config file if it exists.

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

### -Function

The name of the function to add a default parameter for.
Wildcards are supported to match multiple functions.

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

### -Parameter

The name of the parameter to set a default value for.
Wildcards are supported to match multiple parameters.

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

### -Value

The value to assign as the default for the specified parameter.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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

### System.Object

{{ Fill in the Description }}

## NOTES

Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to streamline your PowerShell workflow with persistent default parameters.


## RELATED LINKS

{{ Fill in the related links here }}

