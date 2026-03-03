---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Update-PSConfigFileCredentials

## SYNOPSIS
Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.

## SYNTAX

```
Update-PSConfigFileCredentials [[-RenewSavedPasswords] <String[]>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
This function allows you to renew the self-signed certificate used for credential encryption, and to re-encrypt or update saved credentials for your PowerShell environment.
This is useful when certificates expire, passwords change, or you need to ensure compatibility across PowerShell editions (Core/Desktop).
You can renew all credentials or select specific ones by name.

## EXAMPLES

### EXAMPLE 1
```
Update-PSConfigFileCredentials -RenewSavedPasswords All
```

Prompts to renew all saved credentials in the config file.

### EXAMPLE 2
```
Update-PSConfigFileCredentials -RenewSavedPasswords AdminUser,LabTest
```

Renews only the 'AdminUser' and 'LabTest' credentials.

## PARAMETERS

### -RenewSavedPasswords
Specifies which saved credentials to renew.
Use 'All' to renew all credentials, or provide an array of credential names.
Run in both PowerShell Core and Desktop to ensure compatibility.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If specified, the config file will be deleted before saving the new one.
If not specified and a config file exists, it will be renamed as a backup before saving the new version.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
