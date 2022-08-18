---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Export-PSConfigFilePFX

## SYNOPSIS
Export the PFX file for credentials.

## SYNTAX

```
Export-PSConfigFilePFX [-Path] <DirectoryInfo> [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Export the PFX file for credentials.

## EXAMPLES

### EXAMPLE 1
```
Export-PSConfigFilePFX -Path C:\temp -Credential $creds
```

## PARAMETERS

### -Path
Path where the pfx will be saved.

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
Credential used to export the pfx file.

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
