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
Add-CommandToPSConfigFile [[-ConfigFile] <FileInfo>] [[-ScriptBlockName] <String>] [[-ScriptBlock] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

## EXAMPLES

### EXAMPLE 1
```
Add-CommandToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -ScriptBlockName DriveC -ScriptBlock "get-childitem c:\"
```

## PARAMETERS

### -ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlockName
Name for the scriptblock

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

### -ScriptBlock
The commands to be executed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
