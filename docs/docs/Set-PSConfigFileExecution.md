---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Set-PSConfigFileExecution

## SYNOPSIS
Adds functionality to add the execution to your profile.

## SYNTAX

```
Set-PSConfigFileExecution [-PSProfile <String>] [-DisplayOutput] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds functionality to add the execution to your profile.

## EXAMPLES

### EXAMPLE 1
```
Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
```

## PARAMETERS

### -PSProfile
Enable or disable loading of config when your ps profile is loaded.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: AddScript
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayOutput
Will add the DisplayOutput parameter when setting the invoke command in the profile.

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
