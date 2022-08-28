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
Add-PSDriveToPSConfigFile [[-DriveName] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Add PSDrive to the config file.

## EXAMPLES

### EXAMPLE 1
```
Add-PSDriveToPSConfigFile -DriveName TempDrive
```

## PARAMETERS

### -DriveName
Name of the PSDrive (PSDrive needs to be created first with New-PSDrive)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Will delete the config file before saving the new one.
If false, then the config file will be renamed.

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
