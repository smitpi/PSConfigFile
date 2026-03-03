---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-PSDriveToPSConfigFile

## SYNOPSIS
Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.

## SYNTAX

```
Add-PSDriveToPSConfigFile [[-DriveName] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to register a PowerShell drive (PSDrive) in your configuration file.
When the config is invoked, the drive will be automatically available in your session, streamlining access to file systems, registries, or other providers.
The PSDrive must already exist (use New-PSDrive to create it first).

## EXAMPLES

### EXAMPLE 1
```
New-PSDrive -Name TempDir -PSProvider FileSystem -Root "C:\\Temp"
```

Add-PSDriveToPSConfigFile -DriveName TempDir
Registers the 'TempDir' PSDrive in the config file for automatic use in future sessions.

### EXAMPLE 2
```
Add-PSDriveToPSConfigFile -DriveName ProdModules -Force
```

Adds the 'ProdModules' PSDrive, overwriting the config file if it exists.

## PARAMETERS

### -DriveName
The name of the PSDrive to add.
The drive must already exist in the current session.

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
