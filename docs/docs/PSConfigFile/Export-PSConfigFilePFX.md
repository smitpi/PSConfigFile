---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: Export-PSConfigFilePFX
---

# Export-PSConfigFilePFX

## SYNOPSIS

Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.

## SYNTAX

### __AllParameterSets

```
Export-PSConfigFilePFX [-Path] <DirectoryInfo> [[-Credential] <pscredential>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use this function to export the self-signed certificate (in PFX format) that is used to encrypt and decrypt credentials in your PSConfigFile configuration.
Exporting the certificate allows you to import it on other machines, enabling secure decryption of credentials across trusted systems.
You must provide a credential to protect the exported PFX file.

## EXAMPLES

### EXAMPLE 1

$creds = Get-Credential
Export-PSConfigFilePFX -Path C:\temp -Credential $creds
Exports the certificate to C:\temp, protected by the provided credentials.

## PARAMETERS

### -Credential

The credential (username and password) used to protect the exported PFX file.
Use Get-Credential to create this object.

```yaml
Type: PSCredential
DefaultValue: (Get-Credential -UserName PFXExport -Message 'For the exported pfx file')
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

### -Path

The directory path where the exported PFX file will be saved.
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
Use this to securely transfer your credential encryption certificate to other systems.


## RELATED LINKS

{{ Fill in the related links here }}

