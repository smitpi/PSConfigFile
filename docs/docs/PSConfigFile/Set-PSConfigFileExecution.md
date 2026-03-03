---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Set-PSConfigFileExecution
---

# Set-PSConfigFileExecution

## SYNOPSIS

Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.

## SYNTAX

### Profile (Default)

```
Set-PSConfigFileExecution [-PSProfile <string>] [-DisplayOutput] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function adds or removes the command to invoke your PSConfigFile configuration from your PowerShell profile or a specified module.
This ensures your environment is set up automatically every time you start a new session.
You can also choose to include the DisplayOutput parameter for verbose startup information.

## EXAMPLES

### EXAMPLE 1

Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
Adds the config execution command with detailed output to your PowerShell profile.

### EXAMPLE 2

Set-PSConfigFileExecution -PSProfile RemoveScript
Removes the config execution command from your PowerShell profile.

## PARAMETERS

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

### -DisplayOutput

If specified, adds the DisplayOutput parameter to the invoke command in your profile for detailed output at startup.

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

### -PSProfile

Specifies whether to add or remove the config execution command from your PowerShell profile.
Accepts values like 'AddScript' or 'RemoveScript'.

```yaml
Type: String
DefaultValue: AddScript
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Profile
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
Use this to automate your environment setup every time you launch PowerShell.


## RELATED LINKS

{{ Fill in the related links here }}

