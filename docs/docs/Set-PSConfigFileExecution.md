---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Set-PSConfigFileExecution

## SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

## SYNTAX

### Profile (Default)
```
Set-PSConfigFileExecution [-PSProfile <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Module
```
Set-PSConfigFileExecution [-PSModule <String>] [-ModuleName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

## EXAMPLES

### EXAMPLE 1
```
Set-PSConfigFileExecution -PSProfile AddScript -PSModule AddScript -ModuleName LabScripts
```

## PARAMETERS

### -PSProfile
Enable or disable loading of config when your ps profile is loaded.

```yaml
Type: String
Parameter Sets: Profile
Aliases:

Required: False
Position: Named
Default value: Ignore
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSModule
Enable or disable loading of config when a specific module is loaded.

```yaml
Type: String
Parameter Sets: Module
Aliases:

Required: False
Position: Named
Default value: Ignore
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
Name of the module to be updated.
If the module is not in the standard folders ($env:PSModulePath), then import it into your session first.

```yaml
Type: String
Parameter Sets: Module
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
