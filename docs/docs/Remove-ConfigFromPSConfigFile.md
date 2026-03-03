---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Remove-ConfigFromPSConfigFile

## SYNOPSIS
Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.

## SYNTAX

```
Remove-ConfigFromPSConfigFile [[-Variable] <String[]>] [[-PSDrive] <String[]>] [[-Function] <String[]>]
 [[-Command] <String[]>] [[-Credential] <String[]>] [[-PSDefaults] <String[]>] [[-Location] <String[]>]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to remove a specific configuration item from your config file, such as a PSDrive, function, variable, command, credential, default parameter, or location.
This is useful for cleaning up or updating your configuration as your environment changes.
You can optionally force the config file to be deleted before saving the new one.

## EXAMPLES

### EXAMPLE 1
```
Remove-ConfigFromPSConfigFile -PSDrive ProdMods
```

Removes the 'ProdMods' PSDrive from the config file.

### EXAMPLE 2
```
Remove-ConfigFromPSConfigFile -Variable AzureToken -Force
```

Removes the 'AzureToken' variable, overwriting the config file if it exists.

## PARAMETERS

### -Variable
The name(s) of the variable(s) to remove from the config file.

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
The name(s) of the PSDrive(s) to remove from the config file.

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

### -Function
The name(s) of the function(s) to remove from the config file.

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
The name(s) of the command(s) to remove from the config file.

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
The name(s) of the credential(s) to remove from the config file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSDefaults
The name(s) of the default parameter(s) to remove from the config file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location
If specified, removes the default location from the config file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
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
