---
external help file: PSConfigFile-help.xml
Module Name: PSConfigFile
online version:
schema: 2.0.0
---

# Add-CredentialToPSConfigFile

## SYNOPSIS
Creates a self signed cert, then uses it to securely save a credential to the config file.

## SYNTAX

```
Add-CredentialToPSConfigFile [[-Name] <String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Creates a self signed cert, then uses it to securely save a credential to the config file. 
You can export the cert, and install it on other machines.
Then you would be able to decrypt the password on those machines.

## EXAMPLES

### EXAMPLE 1
```
$labcred = get-credential
```

Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred

## PARAMETERS

### -Name
This name will be used for the variable when invoke command is executed.

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
Credential object to be saved.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
