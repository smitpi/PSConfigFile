---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Set-PSConfigFileExecution

## SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

## SYNTAX

### Profile (Default)
```
Set-PSConfigFileExecution -ConfigFile <FileInfo> [-PSProfile <String>] [-ExecuteNow] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Module
```
Set-PSConfigFileExecution -ConfigFile <FileInfo> [-PSModule <String>] [-PathToPSM1File <FileInfo>]
 [-ExecuteNow] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

## EXAMPLES

### EXAMPLE 1
```
Set-PSConfigFileExecution -ConfigFile C:\Temp\jdh\PSCustomConfig.json -PSProfile AddScript -PSModule AddScript -PathToPSM1File C:\Utils\LabScripts\LabScripts.psm1
```

## PARAMETERS

### -ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

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
Execute the config file, to make sure everything runs as expected.

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

### -PathToPSM1File
Path to the .psm1 file

```yaml
Type: FileInfo
Parameter Sets: Module
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSModule
Enable or disable loading of config when a specific module is loaded.

```yaml
Type: String
Parameter Sets: Module
Aliases:

Required: False
Position: Named
Default value: Ignore
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSProfile
Enable or disable loading of config when your ps profile is loaded.

```yaml
Type: String
Parameter Sets: Profile
Aliases:

Required: False
Position: Named
Default value: Ignore
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
