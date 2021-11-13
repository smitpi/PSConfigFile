---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-AliasToPSConfigFile

## SYNOPSIS
Creates Shortcuts (Aliases) to commands or script blocks

## SYNTAX

```
Add-AliasToPSConfigFile [[-ConfigFile] <FileInfo>] [[-AliasName] <String>] [[-CommandToRun] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates Shortcuts (Aliases) to commands or script blocks

## EXAMPLES

### EXAMPLE 1
```
Add-AliasToPSConfigFile -ConfigFile $PSConfigFile -AliasName psml -CommandToRun "import-module .\*.psm1 -force -verbose"
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

### -AliasName
Name to use for the command

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

### -CommandToRun
Command to run in a string format

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