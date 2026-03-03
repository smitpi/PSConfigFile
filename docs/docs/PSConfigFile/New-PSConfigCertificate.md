---
document type: cmdlet
external help file: PSConfigFile-Help.xml
HelpUri: https://smitpi.github.io/PSConfigFile/New-PSConfigCertificate
Locale: en-US
Module Name: PSConfigFile
ms.date: 03/03/2026
PlatyPS schema version: 2024-05-01
title: New-PSConfigCertificate
---

# New-PSConfigCertificate

## SYNOPSIS

Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.

## SYNTAX

### Set1 (Default)

```
New-PSConfigCertificate [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function generates a new self-signed certificate (or renews an existing one) used to encrypt and decrypt credentials stored in your configuration file.
This ensures your sensitive data remains secure and portable across trusted systems.
After creating the certificate, all saved credentials are re-encrypted for continued security.

## EXAMPLES

### EXAMPLE 1

New-PSConfigCertificate
Creates or renews the self-signed certificate for credential encryption and re-encrypts all saved credentials.

## PARAMETERS

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
Run this if your certificate is expiring or you need to reset credential encryption.


## RELATED LINKS

{{ Fill in the related links here }}

