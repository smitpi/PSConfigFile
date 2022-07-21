---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Show-PSConfigFile

## SYNOPSIS
Display what's configured in the config file.

## SYNTAX

```
Show-PSConfigFile [-ShowLastInvokeOutput] [[-OtherConfigFile] <FileInfo>] [<CommonParameters>]
```

## DESCRIPTION
Display what's configured in the config file.
But doesn't execute the commands

## EXAMPLES

### EXAMPLE 1
```
Show-PSConfigFile -ShowLastInvokeOutput
```

## PARAMETERS

### -ShowLastInvokeOutput
Display the output of the last Invoke-PSConfigFile execution.

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

### -OtherConfigFile
Path to a previously created config file.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
