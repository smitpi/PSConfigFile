---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Export-PSConfigFilePFX

## SYNOPSIS
Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.

## SYNTAX

```
Export-PSConfigFilePFX [-Path] <DirectoryInfo> [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Use this function to export the self-signed certificate (in PFX format) that is used to encrypt and decrypt credentials in your PSConfigFile configuration.
Exporting the certificate allows you to import it on other machines, enabling secure decryption of credentials across trusted systems.
You must provide a credential to protect the exported PFX file.

## EXAMPLES

### EXAMPLE 1
```
$creds = Get-Credential
```

Export-PSConfigFilePFX -Path C:\temp -Credential $creds
Exports the certificate to C:\temp, protected by the provided credentials.

## PARAMETERS

### -Path
The directory path where the exported PFX file will be saved.
The directory will be created if it does not exist.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credential (username and password) used to protect the exported PFX file.
Use Get-Credential to create this object.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-Credential -UserName PFXExport -Message 'For the exported pfx file')
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
