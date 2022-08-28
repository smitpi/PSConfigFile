---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-CommandToPSConfigFile

## SYNOPSIS
Adds a command or script block to the config file, to be executed every time the invoke function is called.

## SYNTAX

```
Add-CommandToPSConfigFile [[-ScriptBlockName] <String>] [[-ScriptBlock] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

## EXAMPLES

### EXAMPLE 1
```
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\"
```

## PARAMETERS

### -ScriptBlockName
Name for the script block

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock
The commands to be executed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
