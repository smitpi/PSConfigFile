---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-VariableToPSConfigFile

## SYNOPSIS
Adds one or more existing variables to the PSConfigFile configuration for automatic session import.

## SYNTAX

```
Add-VariableToPSConfigFile [[-VariableNames] <String[]>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
This function allows you to store the values of existing variables in your configuration file.
When the config is invoked, these variables will be automatically recreated in your session, making it easy to persist tokens, paths, or other important values across PowerShell sessions.
SecureString and PSCredential types are not allowed for security reasons.

## EXAMPLES

### EXAMPLE 1
```
Add-VariableToPSConfigFile -VariableNames AzureToken
```

Adds the 'AzureToken' variable to the config file for automatic import in future sessions.

### EXAMPLE 2
```
Add-VariableToPSConfigFile -VariableNames Path1,Path2 -Force
```

Adds both 'Path1' and 'Path2' variables, overwriting the config file if it exists.

## PARAMETERS

### -VariableNames
The name(s) of the variable(s) to add.
Each variable must already exist in the current session.

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
If specified, the config file will be deleted before saving the new one.
If not specified and a config file exists, it will be renamed as a backup before saving the new version.

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
