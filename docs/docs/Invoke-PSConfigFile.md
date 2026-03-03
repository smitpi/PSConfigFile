---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Invoke-PSConfigFile

## SYNOPSIS
Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.

## SYNTAX

```
Invoke-PSConfigFile [-ConfigFile] <FileInfo> [-DisplayOutput] [<CommonParameters>]
```

## DESCRIPTION
Use this function to load a PSConfigFile XML configuration file and apply all stored settings to your current session.
This includes setting variables, creating PSDrives, defining functions, importing credentials, applying default parameters, setting the working directory, and executing startup commands.
Use this to quickly restore your preferred environment or automate session setup across systems.

## EXAMPLES

### EXAMPLE 1
```
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSConfigFile.xml
```

Loads and applies all settings from the specified config file.

### EXAMPLE 2
```
Invoke-PSConfigFile -ConfigFile .\PSConfigFile.xml -DisplayOutput
```

Runs the config file and displays detailed output for each step.

## PARAMETERS

### -ConfigFile
The path to the configuration XML file created by New-PSConfigFile.
Must have a .xml extension.

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
If specified, displays detailed output of each configuration step.
Otherwise, only completion status is shown.
Use Show-PSConfigFile to display the last execution output.

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
