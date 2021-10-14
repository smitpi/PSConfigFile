---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Invoke-PSConfigFile

## SYNOPSIS
Executes the config from the json file

## SYNTAX

```
Invoke-PSConfigFile [-ConfigFile] <FileInfo> [<CommonParameters>]
```

## DESCRIPTION
Executes the config from the json file

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-PSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json
```

Executes the commands from C:\Temp\jdh\PSCustomConfig.json

## PARAMETERS

### -ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
