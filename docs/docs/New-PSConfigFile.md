---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# New-PSConfigFile

## SYNOPSIS
Creates a new config file

## SYNTAX

```
New-PSConfigFile [-ConfigDir] <DirectoryInfo> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new config file.
If a config file already exists in that folder, it will be renamed.
It will also create a log file in the same directory.
Log file will be used on every execution.

## EXAMPLES

### EXAMPLE 1
```
New-PSConfigFile -ConfigDir C:\Temp\jdh
```

## PARAMETERS

### -ConfigDir
Directory to create config file

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
