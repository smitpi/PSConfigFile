---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Import-PSConfigFilePFX

## SYNOPSIS
Import the PFX file for credentials

## SYNTAX

```
Import-PSConfigFilePFX [-Path] <FileInfo> [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Import the PFX file for credentials

## EXAMPLES

### EXAMPLE 1
```
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds
```

## PARAMETERS

### -Path
Path to the PFX file.

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
Credential used to create the pfx file.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
