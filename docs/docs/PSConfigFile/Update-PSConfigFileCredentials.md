---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Update-PSConfigFileCredentials
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Update-PSConfigFileCredentials
---

# Update-PSConfigFileCredentials

## SYNOPSIS

Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Update-PSConfigFileCredentials [[-RenewSavedPasswords] <string[]>] [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function allows you to renew the self-signed certificate used for credential encryption, and to re-encrypt or update saved credentials for your PowerShell environment.
This is useful when certificates expire, passwords change, or you need to ensure compatibility across PowerShell editions (Core/Desktop).
You can renew all credentials or select specific ones by name.

## EXAMPLES

### EXAMPLE 1

Update-PSConfigFileCredentials -RenewSavedPasswords All
Prompts to renew all saved credentials in the config file.

### EXAMPLE 2

Update-PSConfigFileCredentials -RenewSavedPasswords AdminUser,LabTest
Renews only the 'AdminUser' and 'LabTest' credentials.

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

### -RenewSavedPasswords

Specifies which saved credentials to renew.
Use 'All' to renew all credentials, or provide an array of credential names.
Run in both PowerShell Core and Desktop to ensure compatibility.

```yaml
Type: String[]
DefaultValue: All
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
Use this to keep your credential storage secure and up to date.


## RELATED LINKS

{{ Fill in the related links here }}

