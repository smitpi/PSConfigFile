---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Set-CredentialsInPSConfigFile

## SYNOPSIS
Allows you to renew the certificate,saved passwords and export/import pfx file

## SYNTAX

### Set1 (Default)
```
Set-CredentialsInPSConfigFile [<CommonParameters>]
```

### Renew
```
Set-CredentialsInPSConfigFile [-RenewSelfSignedCert] [-RenewSavedPasswords] [<CommonParameters>]
```

### Export
```
Set-CredentialsInPSConfigFile [-ExportPFX] [-ExportPath <DirectoryInfo>] [-Credential <PSCredential>]
 [<CommonParameters>]
```

### Import
```
Set-CredentialsInPSConfigFile [-ImportPFX] [-PFXFilePath <FileInfo>] [-Credential <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
Allows you to renew the certificate,saved passwords and export/import pfx file

## EXAMPLES

### EXAMPLE 1
```
Set-CredentialsInPSConfigFile -ExportPFX -ExportPath C:\Temp\
```

## PARAMETERS

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

### -RenewSavedPasswords
Re-encrypts the passwords for the current PS Edition.
Run it in PS core and desktop to save both version.

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

### -ImportPFX
Import the previously exported PFX file.

```yaml
Type: SwitchParameter
Parameter Sets: Import
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PFXFilePath
path to the .pfx file.

```yaml
Type: FileInfo
Parameter Sets: Import
Aliases:

Required: False
Position: Named
Default value: "$($env:temp)"
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPath
Where to export the .pfx file.

```yaml
Type: DirectoryInfo
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: "$($env:temp)"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
This password will be used to import or export the .pfx file.

```yaml
Type: PSCredential
Parameter Sets: Export, Import
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
