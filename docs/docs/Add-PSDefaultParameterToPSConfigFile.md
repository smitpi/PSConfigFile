---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-PSDefaultParameterToPSConfigFile

## SYNOPSIS
Adds a default parameter value for a function to the PSConfigFile configuration.

## SYNTAX

```
Add-PSDefaultParameterToPSConfigFile [-Function] <String> [-Parameter] <String> [-Value] <String> [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
This function allows you to specify default parameter values for any PowerShell function.
These defaults are stored in your configuration file and will be automatically applied in your session, saving you from repeatedly specifying common parameters.
Wildcards can be used to apply defaults to multiple functions or parameters.

## EXAMPLES

### EXAMPLE 1
```
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\\temp\\PSLauncherConfig.json
```

Sets a default value for the 'PSLauncherConfigFile' parameter of the 'Start-PSLauncher' function.

### EXAMPLE 2
```
Add-PSDefaultParameterToPSConfigFile -Function *-Item -Parameter Path -Value C:\\Data -Force
```

Sets a default 'Path' for all functions ending with '-Item', overwriting the config file if it exists.

## PARAMETERS

### -Function
The name of the function to add a default parameter for.
Wildcards are supported to match multiple functions.

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

### -Parameter
The name of the parameter to set a default value for.
Wildcards are supported to match multiple parameters.

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

### -Value
The value to assign as the default for the specified parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

### System.Object[]
## NOTES

## RELATED LINKS
