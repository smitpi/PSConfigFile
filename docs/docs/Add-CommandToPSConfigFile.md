---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-CommandToPSConfigFile

## SYNOPSIS
Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.

## SYNTAX

```
Add-CommandToPSConfigFile [[-ScriptBlockName] <String>] [[-ScriptBlock] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to store custom commands or script blocks in your configuration file.
These commands will be executed every time the config file is invoked using Invoke-PSConfigFile.
This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

## EXAMPLES

### EXAMPLE 1
```
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\\"
```

Adds a script block named 'DriveC' that lists the contents of the C drive every time the config is invoked.

### EXAMPLE 2
```
Add-CommandToPSConfigFile -ScriptBlockName Startup -ScriptBlock "Write-Host 'Welcome!'" -Force
```

Adds a script block named 'Startup' that displays a welcome message, overwriting the config file if it exists.

## PARAMETERS

### -ScriptBlockName
The unique name to assign to the script block.
This name is used to identify and manage the command within the config file.

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

### -ScriptBlock
The PowerShell command(s) or script block to be executed.
Provide as a string.
Example: "Get-ChildItem C:\\\\Logs | Out-File C:\\\\log.txt"

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
