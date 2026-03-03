---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-FunctionToPSConfigFile

## SYNOPSIS
Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.

## SYNTAX

```
Add-FunctionToPSConfigFile [[-FunctionName] <String>] [[-CommandToRun] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to define named PowerShell functions (shortcuts) that execute specific commands or script blocks.
These functions are stored in your configuration file and can be invoked automatically or manually, streamlining repetitive tasks and environment setup.
This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

## EXAMPLES

### EXAMPLE 1
```
Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "Import-Module .\*.psm1 -Force -Verbose"
```

Adds a function named 'psml' that imports all PowerShell modules in the current directory with force and verbose options.

### EXAMPLE 2
```
Add-FunctionToPSConfigFile -FunctionName CleanLogs -CommandToRun "Remove-Item C:\\Logs\\* -Recurse -Force" -Force
```

Adds a function named 'CleanLogs' to delete all log files, overwriting the config file if it exists.

## PARAMETERS

### -FunctionName
The unique name to assign to the custom function.
This name is used to identify and manage the function within the config file.

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

### -CommandToRun
The PowerShell command(s) or script block to be executed by the function.
Provide as a string.
Example: "Import-Module .\*.psm1 -Force -Verbose"

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
If specified, the config file will be deleted before saving the new one.
If not specified and a config file exists, it will be renamed as a backup before saving the new version.

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
