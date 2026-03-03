---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-LocationToPSConfigFile

## SYNOPSIS
Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

## SYNTAX

```
Add-LocationToPSConfigFile [[-PSDriveName] <String>] [[-FolderPath] <DirectoryInfo>] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
Specifies a default working location for your PowerShell session, either as a folder path or a PSDrive.
When the config file is invoked using Invoke-PSConfigFile, your session will automatically change to this location.
This streamlines your workflow and ensures you always start in the correct directory or drive.

## EXAMPLES

### EXAMPLE 1
```
Add-LocationToPSConfigFile -PSDriveName temp
```

Sets the default location to the 'temp' PSDrive when the config is invoked.

### EXAMPLE 2
```
Add-LocationToPSConfigFile -FolderPath C:\temp
```

Sets the default location to the 'C:\temp' folder when the config is invoked.

## PARAMETERS

### -PSDriveName
The name of the PowerShell drive to set as the default location.
Must be a valid PSDrive.
Use this parameter if you want to set a PSDrive as the start-up location.

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

### -FolderPath
The path to the folder to set as the default location.
Must be a valid directory.
Use this parameter if you want to set a filesystem folder as the start-up location.

```yaml
Type: DirectoryInfo
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
