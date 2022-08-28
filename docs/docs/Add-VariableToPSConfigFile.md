---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-VariableToPSConfigFile

## SYNOPSIS
Adds variable to the config file.

## SYNTAX

```
Add-VariableToPSConfigFile [[-VariableNames] <String[]>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Adds variable to the config file.

## EXAMPLES

### EXAMPLE 1
```
Add-VariableToPSConfigFile -VariableNames AzureToken
```

## PARAMETERS

### -VariableNames
The name of the variable.
(Needs to exist already)

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
