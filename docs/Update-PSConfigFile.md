---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Update-PSConfigFile

## SYNOPSIS
{{ updates the config file to run with a module or ps profile }}

## SYNTAX

```
Update-PSConfigFile -ConfigFile <FileInfo> [-AddToProfile <String>] [-PSModuleFile <String>]
 [-PathToPSM1File <FileInfo>] [-ExecuteNow] [<CommonParameters>]
```

## DESCRIPTION
{{ updates the config file to run with a module or ps profile  }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Update-PSConfigFile -ConfigFile ... -AddToProfile AddScript -PSModuleFile Ignore -PathToPSM1File ...}}
```

{{add script to profile and remove from module }}

## PARAMETERS

### -AddToProfile
{{ add to profile }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AddScript, RemoveScript, Ignore

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigFile
{{ path to json }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExecuteNow
{{ Fill ExecuteNow Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSModuleFile
{{ Fill PSModuleFile Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AddScript, RemoveScript, Ignore

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PathToPSM1File
{{ Fill PathToPSM1File Description }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
