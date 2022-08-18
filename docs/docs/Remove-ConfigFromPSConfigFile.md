---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Remove-ConfigFromPSConfigFile

## SYNOPSIS
Removes a item from the config file.

## SYNTAX

```
Remove-ConfigFromPSConfigFile [[-Config] <String>] [[-Value] <String>] [<CommonParameters>]
```

## DESCRIPTION
Removes a item from the config file.

## EXAMPLES

### EXAMPLE 1
```
Remove-ConfigFromPSConfigFile -PSDrive ProdMods
```

### EXAMPLE 2
```
Remove-ConfigFromPSConfigFile -Config PSDrive -Value ProdMods
```

## PARAMETERS

### -Config
Which config item to remove.

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

### -Value
The value of the config item to filter

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
