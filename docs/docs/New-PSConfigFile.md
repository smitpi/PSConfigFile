---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# New-PSConfigFile

## SYNOPSIS
Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.

## SYNTAX

```
New-PSConfigFile [-ConfigDir] <DirectoryInfo> [[-BackupsToKeep] <Int32>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function initializes a new configuration file in the specified directory, capturing your environment's settings, drives, functions, credentials, variables, and more.
If a config file already exists in the folder, it will be renamed as a backup before creating the new one.
You can specify how many backup copies to keep when the config changes.

## EXAMPLES

### EXAMPLE 1
```
New-PSConfigFile -ConfigDir C:\\Temp\\config -BackupsToKeep 3
```

Creates a new config file in C:\Temp\config and keeps up to 3 backup copies.

### EXAMPLE 2
```
New-PSConfigFile -ConfigDir .
```

Creates a new config file in the current directory with the default number of backups.

## PARAMETERS

### -ConfigDir
The directory where the new config file will be created.
The directory will be created if it does not exist.

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

### -BackupsToKeep
The number of backup copies to keep when the config file is changed.
Older backups beyond this number will be deleted automatically.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3
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
