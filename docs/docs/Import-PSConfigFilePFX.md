---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Import-PSConfigFilePFX

## SYNOPSIS
Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.

## SYNTAX

```
Import-PSConfigFilePFX [-Path] <FileInfo> [[-Credential] <PSCredential>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to import a self-signed certificate (in PFX format) that is used to decrypt credentials in your PSConfigFile configuration.
This is useful when moving your configuration to a new system or restoring access to encrypted credentials.
You must provide the credential used to protect the PFX file.
Optionally, you can force the import to override existing certificates.

## EXAMPLES

### EXAMPLE 1
```
$creds = Get-Credential
```

Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds
Imports the certificate from C:\temp, using the provided credentials for decryption.

### EXAMPLE 2
```
Import-PSConfigFilePFX -Path .\PSConfigFileCert.pfx -Credential (Get-Credential) -Force
```

Imports and overwrites any existing certificate with the same name.

## PARAMETERS

### -Path
The path to the PFX file to import.
Must be a valid .pfx file.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credential (username and password) that was used to protect the PFX file.
Use Get-Credential to create this object.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-Credential -UserName InportPFX -Message 'For the imported pfx file')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If specified, will override any existing certificates with the same name.

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

### System.Object[]
## NOTES

## RELATED LINKS
