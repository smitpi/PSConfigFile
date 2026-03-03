---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# New-PSConfigCertificate

## SYNOPSIS
Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.

## SYNTAX

```
New-PSConfigCertificate [<CommonParameters>]
```

## DESCRIPTION
This function generates a new self-signed certificate (or renews an existing one) used to encrypt and decrypt credentials stored in your configuration file.
This ensures your sensitive data remains secure and portable across trusted systems.
After creating the certificate, all saved credentials are re-encrypted for continued security.

## EXAMPLES

### EXAMPLE 1
```
New-PSConfigCertificate
```

Creates or renews the self-signed certificate for credential encryption and re-encrypts all saved credentials.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
