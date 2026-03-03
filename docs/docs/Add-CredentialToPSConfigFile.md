---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-CredentialToPSConfigFile

## SYNOPSIS
Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.

## SYNTAX

```
Add-CredentialToPSConfigFile [[-Name] <String>] [[-Credential] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use this function to securely store a PowerShell credential object in your configuration file.
A self-signed certificate is created (if one does not already exist) and used to encrypt the credential.
The certificate can be exported and installed on other machines, allowing you to decrypt and use the credential securely across trusted systems.
This is ideal for automating scripts that require credentials without exposing sensitive information in plain text.

## EXAMPLES

### EXAMPLE 1
```
$labcred = Get-Credential
```

Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred
Prompts for credentials and saves them securely in the config file under the name 'LabTest'.

### EXAMPLE 2
```
Add-CredentialToPSConfigFile -Name AdminUser -Credential (Get-Credential) -Force
```

Saves a credential named 'AdminUser', overwriting the config file if it exists.

## PARAMETERS

### -Name
The unique variable name to assign to the credential in the config file.
This name is used to reference the credential when invoking commands from the config.

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

### -Credential
The PowerShell credential object to be securely stored.
Use Get-Credential to create this object first.

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

### System.Object[]
## NOTES

## RELATED LINKS
