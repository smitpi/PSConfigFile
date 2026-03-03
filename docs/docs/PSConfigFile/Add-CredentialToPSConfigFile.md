---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Add-CredentialToPSConfigFile
---

# Add-CredentialToPSConfigFile

## SYNOPSIS

Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.

## SYNTAX

### __AllParameterSets

```
Add-CredentialToPSConfigFile [[-Name] <string>] [[-Credential] <pscredential>] [-Force]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to securely store a PowerShell credential object in your configuration file.
A self-signed certificate is created (if one does not already exist) and used to encrypt the credential.
The certificate can be exported and installed on other machines, allowing you to decrypt and use the credential securely across trusted systems.
This is ideal for automating scripts that require credentials without exposing sensitive information in plain text.

## EXAMPLES

### EXAMPLE 1

$labcred = Get-Credential
Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred
Prompts for credentials and saves them securely in the config file under the name 'LabTest'.

### EXAMPLE 2

Add-CredentialToPSConfigFile -Name AdminUser -Credential (Get-Credential) -Force
Saves a credential named 'AdminUser', overwriting the config file if it exists.

## PARAMETERS

### -Credential

The PowerShell credential object to be securely stored.
Use Get-Credential to create this object.

```yaml
Type: PSCredential
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

### -Name

The unique variable name to assign to the credential in the config file.
This name is used to reference the credential when invoking commands from the config.

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

### System.Object

{{ Fill in the Description }}

## NOTES

Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.
Credentials are encrypted using a self-signed certificate for security and portability.


## RELATED LINKS

{{ Fill in the related links here }}

