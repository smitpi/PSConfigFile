---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-VariableToPSConfigFile

## SYNOPSIS
Adds variable to the config file

## SYNTAX

```
Add-VariableToPSConfigFile [[-ConfigFile] <FileInfo>] [[-VariableNames] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Adds variable to the config file. The Variable needs to exist already

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-VariableToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -VariableNames blah
```

Adds the variable $blah to the config file

### Example 2

```powershell
PS C:\> Add-VariableToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -VariableNames b*
```

Adds all variables starting with b to the config file

## PARAMETERS

### -ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VariableNames
The name of the variable. (Needs to exist already)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
