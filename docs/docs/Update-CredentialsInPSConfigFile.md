---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Update-CredentialsInPSConfigFile

## SYNOPSIS
Allows you to renew the certificate or saved passwords.

## SYNTAX

```
Update-CredentialsInPSConfigFile [-RenewSelfSignedCert] [[-RenewSavedPasswords] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Allows you to renew the certificate or saved passwords.

## EXAMPLES

### EXAMPLE 1
```
Update-CredentialsInPSConfigFile -RenewSavedPasswords All
```

## PARAMETERS

### -RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RenewSavedPasswords
Re-encrypts the passwords for the current PS Edition.
Run it in PS core and desktop to save both version.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
