---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Import-PSConfigFilePFX
---

# Import-PSConfigFilePFX

## SYNOPSIS

Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Import-PSConfigFilePFX [-Path] <FileInfo> [[-Credential] <pscredential>] [-Force]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to import a self-signed certificate (in PFX format) that is used to decrypt credentials in your PSConfigFile configuration.
This is useful when moving your configuration to a new system or restoring access to encrypted credentials.
You must provide the credential used to protect the PFX file.
Optionally, you can force the import to override existing certificates.

## EXAMPLES

### EXAMPLE 1

$creds = Get-Credential
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds
Imports the certificate from C:\temp, using the provided credentials for decryption.

### EXAMPLE 2

Import-PSConfigFilePFX -Path .\PSConfigFileCert.pfx -Credential (Get-Credential) -Force
Imports and overwrites any existing certificate with the same name.

## PARAMETERS

### -Credential

The credential (username and password) that was used to protect the PFX file.
Use Get-Credential to create this object.

```yaml
Type: PSCredential
DefaultValue: (Get-Credential -UserName InportPFX -Message 'For the imported pfx file')
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

If specified, will override any existing certificates with the same name.

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

### -Path

The path to the PFX file to import.
Must be a valid .pfx file.

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
Use this to restore credential decryption capability on new or rebuilt systems.


## RELATED LINKS

{{ Fill in the related links here }}

