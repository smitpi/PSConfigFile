---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-CredentialToPSConfigFile

## SYNOPSIS
Creates a self signed cert, then uses it to securely save a credentials to the config file.

## SYNTAX

### Def (Default)
```
Add-CredentialToPSConfigFile [-Name <String>] [-Credentials <PSCredential>] [<CommonParameters>]
```

### Renew
```
Add-CredentialToPSConfigFile [-RenewSelfSignedCert] [<CommonParameters>]
```

### Export
```
Add-CredentialToPSConfigFile [-ExportPFX] [-ExportPath <DirectoryInfo>] [-ExportCredentials <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a self signed cert, then uses it to securely save a credentials to the config file. 
You can export the cert, and install it on other machines.
Then you would be able to decrypt the password on those machines.

## EXAMPLES

### EXAMPLE 1
```
$labcred = get-credential
```

Add-CredentialToPSConfigFile -Name LabTest -Credentials $labcred

## PARAMETERS

### -Name
This name will be used for the variable when invoke command is executed.

```yaml
Type: String
Parameter Sets: Def
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credentials
Credential object to be saved.

```yaml
Type: PSCredential
Parameter Sets: Def
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

```yaml
Type: SwitchParameter
Parameter Sets: Renew
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPFX
Select to export a pfx file, that can be installed on other machines.

```yaml
Type: SwitchParameter
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPath
Where to save the pfx file.

```yaml
Type: DirectoryInfo
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportCredentials
The password will be used to export the pfx file.

```yaml
Type: PSCredential
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
