---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-PSDefaultParameterToPSConfigFile

## SYNOPSIS
Add PSDefaultParameterValues to the config file

## SYNTAX

```
Add-PSDefaultParameterToPSConfigFile [-Function] <String> [-Parameter] <String> [-Value] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Add PSDefaultParameterValues to the config file

## EXAMPLES

### EXAMPLE 1
```
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\temp\PSLauncherConfig.json
```

## PARAMETERS

### -Function
The Function to add

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameter
The Parameter of that function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
Value of the parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
