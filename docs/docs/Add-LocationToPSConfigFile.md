---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-LocationToPSConfigFile

## SYNOPSIS
Adds default location to the config file.

## SYNTAX

```
Add-LocationToPSConfigFile [-LocationType] <String> [-Path] <String> [-Force] [<CommonParameters>]
```

## DESCRIPTION
Adds default location to the config file.

## EXAMPLES

### EXAMPLE 1
```
Add-LocationToPSConfigFile -LocationType PSDrive -Path temp
```

### EXAMPLE 2
```
Add-LocationToPSConfigFile -LocationType Folder -Path c:\temp
```

## PARAMETERS

### -LocationType
Is the location a folder or a PS-Drive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to the folder or the PS-Drive name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
