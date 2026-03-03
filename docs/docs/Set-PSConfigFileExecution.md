---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Set-PSConfigFileExecution

## SYNOPSIS
Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.

## SYNTAX

```
Set-PSConfigFileExecution [-PSProfile <String>] [-DisplayOutput] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function adds or removes the command to invoke your PSConfigFile configuration from your PowerShell profile or a specified module.
This ensures your environment is set up automatically every time you start a new session.
You can also choose to include the DisplayOutput parameter for verbose startup information.

## EXAMPLES

### EXAMPLE 1
```
Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
```

Adds the config execution command with detailed output to your PowerShell profile.

### EXAMPLE 2
```
Set-PSConfigFileExecution -PSProfile RemoveScript
```

Removes the config execution command from your PowerShell profile.

## PARAMETERS

### -PSProfile
Specifies whether to add or remove the config execution command from your PowerShell profile.
Accepts values like 'AddScript' or 'RemoveScript'.

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
If specified, adds the DisplayOutput parameter to the invoke command in your profile for detailed output at startup.

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
