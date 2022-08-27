---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Invoke-PSConfigFile

## SYNOPSIS
Executes the config from the json file.

## SYNTAX

```
Invoke-PSConfigFile [-ConfigFile] <FileInfo> [-DisplayOutput] [<CommonParameters>]
```

## DESCRIPTION
Executes the config from the json file.

## EXAMPLES

### EXAMPLE 1
```
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSConfigFile.xml
```

## PARAMETERS

### -ConfigFile
Path to the the config file that was created by New-PSConfigFile

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayOutput
By default no output is displayed, switch this on to display the output.
Or use Show-PSConfigFile to display the last execution.

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
