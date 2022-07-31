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
Remove-ConfigFromPSConfigFile [[-Variable] <String[]>] [[-PSDrive] <String[]>] [[-PSAlias] <String[]>]
 [[-Command] <String[]>] [[-Credential] <SecureString[]>] [-Location] [<CommonParameters>]
```

## DESCRIPTION
Removes a item from the config file.

## EXAMPLES

### EXAMPLE 1
```
Remove-ConfigFromPSConfigFile -PSDrive ProdMods
```

## PARAMETERS

### -Variable
Name of the variable to remove.

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

### -PSDrive
Name of the PSDrive to remove.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSAlias
Name of the Alias to remove.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command
Name of the Command to remove.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Name of the Credential to remove.

```yaml
Type: SecureString[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location
Set Location to blank again.

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
