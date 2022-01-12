---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-PSDriveToPSConfigFile

## SYNOPSIS
Add PSDrive to the config file.

## SYNTAX

```
Add-PSDriveToPSConfigFile [[-ConfigFile] <FileInfo>] [[-DriveName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Add PSDrive to the config file.

## EXAMPLES

### EXAMPLE 1
```
Add-PSDriveToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -DriveName TempDrive
```

## PARAMETERS

### -ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriveName
Name of the PSDrive (PSDrive needs to be created first with New-PSDrive)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
