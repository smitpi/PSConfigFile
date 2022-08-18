#region Public Functions
#region Add-AliasToPSConfigFile.ps1
######## Function 1 of 15 ##################
# Function:         Add-AliasToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:08:33
# Synopsis:         Creates Shortcuts (Aliases) to commands or script blocks
#############################################
 
<#
.SYNOPSIS
Creates Shortcuts (Aliases) to commands or script blocks

.DESCRIPTION
Creates Shortcuts (Aliases) to commands or script blocks

.PARAMETER AliasName
Name to use for the command

.PARAMETER CommandToRun
Command to run in a string format

.EXAMPLE
Add-AliasToPSConfigFile -AliasName psml -CommandToRun "import-module .\*.psm1 -force -verbose"

#>
Function Add-AliasToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-AliasToPSConfigFile')]
    PARAM(
        [ValidateNotNullOrEmpty()]
        [string]$AliasName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Alias $($AliasName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    $SetAlias = @{}

    if ($Json.PSAlias.psobject.Properties.name -like 'Default' -and
        $Json.PSAlias.psobject.Properties.value -like 'Default') {
        $SetAlias = @{
            $AliasName = $CommandToRun
        }
    } else {
        $members = $Json.PSAlias | Get-Member -MemberType NoteProperty
        foreach ($mem in $members) {
            $SetAlias += @{
                $mem.Name = $json.PSAlias.$($mem.Name)
            }
        }
        $SetAlias += @{
            $AliasName = $CommandToRun
        }
    }

    $Update = [psobject]@{
        Userdata    = $userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $SetAlias
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Alias added'
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function
 
Export-ModuleMember -Function Add-AliasToPSConfigFile
#endregion
 
#region Add-CommandToPSConfigFile.ps1
######## Function 2 of 15 ##################
# Function:         Add-CommandToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:08:24
# Synopsis:         Adds a command or script block to the config file, to be executed every time the invoke function is called.
#############################################
 
<#
.SYNOPSIS
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.PARAMETER ScriptBlockName
Name for the script block

.PARAMETER ScriptBlock
The commands to be executed

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\"

#>
Function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    PARAM(
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    ## TODO Allow user to modify the order
    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Command $($ScriptBlockName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    $Execute = @{}
    if ($Json.Execute.psobject.Properties.name -like 'Default' -and
        $Json.Execute.psobject.Properties.value -like 'Default') {
        $Execute += @{
            "[0]-$ScriptBlockName" = $($ScriptBlock.ToString())
        }
    }
    else {
        $Index = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name | Select-Object -Last 1
        [int]$NewTaskIndex = [int]($Index | ForEach-Object { $_.name.split('-')[0].replace('[', '').replace(']', '') }) + 1
        $NewScriptBlockName = '[' + $($NewTaskIndex.ToString()) + ']-' + $ScriptBlockName
        $members = $Json.Execute | Get-Member -MemberType NoteProperty | Sort-Object -Property Name
        foreach ($mem in $members) {
            $Execute += @{
                $mem.Name = $json.Execute.$($mem.Name)
            }
        }
        $Execute += @{
            $NewScriptBlockName = $($ScriptBlock.ToString())
        }
    }
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Command added'
        Write-Output "ConfigFile: $($confile.FullName)"
    }
    catch { Write-Error "Error: `n $_" }



} #end Function
 
Export-ModuleMember -Function Add-CommandToPSConfigFile
#endregion
 
#region Add-CredentialToPSConfigFile.ps1
######## Function 3 of 15 ##################
# Function:         Add-CredentialToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/21 03:47:31
# ModifiedOn:       2022/08/18 08:07:32
# Synopsis:         Creates a self signed cert, then uses it to securely save a credential to the config file.
#############################################
 
<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credential to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credential to the config file.

.EXAMPLE
Add-CredentialToPSConfigFile

#>

<#
.SYNOPSIS
Creates a self signed cert, then uses it to securely save a credential to the config file.

.DESCRIPTION
Creates a self signed cert, then uses it to securely save a credential to the config file. 
You can export the cert, and install it on other machines. Then you would be able to decrypt the password on those machines.

.PARAMETER Name
This name will be used for the variable when invoke command is executed.

.PARAMETER Credential
Credential object to be saved.

.EXAMPLE
$labcred = get-credential
Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred

#>
Function Add-CredentialToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Name,
		[pscredential]$Credential
	)

 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$userdata = [PSCustomObject]@{
		Owner             = $json.Userdata.Owner
		CreatedOn         = $json.Userdata.CreatedOn
		PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
		Path              = $json.Userdata.Path
		Hostname          = $json.Userdata.Hostname
		PSEdition         = $json.Userdata.PSEdition
		OS                = $json.Userdata.OS
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = (Get-Date -Format u)
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = "Add Credencial $($Name)"
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}

	$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	if (-not($selfcert)) {
		$SelfSignedCertParams = @{
			DnsName           = 'PSConfigFileCert'
			KeyDescription    = 'PowerShell Credencial Encryption-Decryption Key'
			Provider          = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
			KeyFriendlyName   = 'PSConfigFileCert'
			FriendlyName      = 'PSConfigFileCert'
			Subject           = 'PSConfigFileCert'
			KeyUsage          = 'DataEncipherment'
			Type              = 'DocumentEncryptionCert'
			HashAlgorithm     = 'sha256'
			CertStoreLocation = 'Cert:\\CurrentUser\\My'
			NotAfter          = (Get-Date).AddMonths(2)
			KeyExportPolicy   = 'Exportable'
		} # end params
		New-SelfSignedCertificate @SelfSignedCertParams | Out-Null
		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	}

	$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
	$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
	[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
	$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
	if ($PSVersionTable.PSEdition -like 'Desktop') {
		$Edition = 'PSDesktop'
		$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)
	} else {
		$Edition = 'PSCore'
		$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
	}
	$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
	
	$Update = @()
	[System.Collections.ArrayList]$SetCreds = @()
		
	if ($Json.PSCreds.psobject.Properties.name -like 'Default' -and
		$Json.PSCreds.psobject.Properties.value -like 'Default') {
				
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	} else {
		$Json.PSCreds | ForEach-Object {[void]$SetCreds.Add($_)}
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $Credential.UserName
				EncryptedPwd = $EncryptedPwd
			})
	}

	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $Json.PSDrive
		PSAlias     = $Json.PSAlias
		PSCreds     = $SetCreds
		PSDefaults  = $Json.PSDefaults
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	try {
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
		Write-Output 'Credential added'
		Write-Output "ConfigFile: $($confile.FullName)"
	} catch { Write-Error "Error: `n $_" }
} #end Function
 
Export-ModuleMember -Function Add-CredentialToPSConfigFile
#endregion
 
#region Add-LocationToPSConfigFile.ps1
######## Function 4 of 15 ##################
# Function:         Add-LocationToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:08:17
# Synopsis:         Adds default location to the config file.
#############################################
 
<#
.SYNOPSIS
Adds default location to the config file.

.DESCRIPTION
Adds default location to the config file.

.PARAMETER LocationType
Is the location a folder or a PS-Drive.

.PARAMETER Path
Path to the folder or the PS-Drive name.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType PSDrive -Path temp

.EXAMPLE
Add-LocationToPSConfigFile -LocationType Folder -Path c:\temp

#>
Function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    PARAM(
        [Parameter(Mandatory = $true)]
        [validateSet('PSDrive', 'Folder')]
        [string]$LocationType,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { ( Test-Path $_) -or ( [bool](Get-PSDrive $_)) })]
        [string]$Path
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    try {
        if ($LocationType -like 'PSDrive') {
            $check = Get-PSDrive $Path -ErrorAction Stop
            [string]$AddPath = "$($path)"
        }
        if ($LocationType -like 'Folder') {
            [string]$AddPath = (Get-Item $path).FullName
        }
    }
    catch { throw 'Could not find path' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Location $($Path)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    $SetLocation = @{}
    $SetLocation += @{
        WorkerDir = $($AddPath)
    }
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Location added'
        Write-Output "ConfigFile: $($confile.FullName)"
    }
    catch { Write-Error "Error: `n $_" }

} #end Function
 
Export-ModuleMember -Function Add-LocationToPSConfigFile
#endregion
 
#region Add-PSDefaultParameterToPSConfigFile.ps1
######## Function 5 of 15 ##################
# Function:         Add-PSDefaultParameterToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/18 07:54:55
# ModifiedOn:       2022/08/18 08:40:16
# Synopsis:         Add PSDefaultParameterValues to the config file
#############################################
 
<#
.SYNOPSIS
Add PSDefaultParameterValues to the config file

.DESCRIPTION
Add PSDefaultParameterValues to the config file

.PARAMETER Function
The Function to add

.PARAMETER Parameter
The Parameter of that function.

.PARAMETER Value
Value of the parameter.

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\temp\PSLauncherConfig.json

#>
Function Add-PSDefaultParameterToPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile')]
	[OutputType([System.Object[]])]
	PARAM(
		[string]$Function,
		[string]$Parameter,
		[string]$Value
	)

try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$userdata = [PSCustomObject]@{
		Owner             = $json.Userdata.Owner
		CreatedOn         = $json.Userdata.CreatedOn
		PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
		Path              = $json.Userdata.Path
		Hostname          = $json.Userdata.Hostname
		PSEdition         = $json.Userdata.PSEdition
		OS                = $json.Userdata.OS
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = (Get-Date -Format u)
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = "Add PSDefaultParameter $($Name)"
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}
	[System.Collections.generic.List[PSObject]]$PSDefaultObject = @()
	if ($Json.PSDefaults.psobject.Properties.name -like 'Default' -and
		$Json.PSDefaults.psobject.Properties.value -like 'Default') {
		
	[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	} else {
		$Json.PSDefaults | ForEach-Object {[void]$PSDefaultObject.Add($_)}
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	}
	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $Json.PSDrive
		PSAlias     = $Json.PSAlias
		PSCreds     = $Json.PSCreds
		PSDefaults  = $PSDefaultObject
		SetLocation = $Json.SetLocation
		SetVariable = $Json.SetVariable
		Execute     = $Json.Execute
	}
	try {
		$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
		Write-Output 'PSDefaults Added'
		Write-Output "ConfigFile: $($confile.FullName)"
	} catch { Write-Error "Error: `n $_" }
} #end Function
 
Export-ModuleMember -Function Add-PSDefaultParameterToPSConfigFile
#endregion
 
#region Add-PSDriveToPSConfigFile.ps1
######## Function 6 of 15 ##################
# Function:         Add-PSDriveToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:08:01
# Synopsis:         Add PSDrive to the config file.
#############################################
 
<#
.SYNOPSIS
Add PSDrive to the config file.

.DESCRIPTION
Add PSDrive to the config file.

.PARAMETER DriveName
Name of the PSDrive (PSDrive needs to be created first with New-PSDrive)

.EXAMPLE
Add-PSDriveToPSConfigFile -DriveName TempDrive

#>
Function Add-PSDriveToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile')]
    PARAM(
        [ValidateScript( { ( Get-PSDrive $_) })]
        [string]$DriveName
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add PS Drive $($DriveName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    $SetPSDrive = @{}
    $InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name, Root
    if ($null -eq $InputDrive) { Write-Error 'Unknown psdrive'; break }

    if ($Json.PSDrive.psobject.Properties.name -like 'Default' -and
        $Json.PSDrive.psobject.Properties.value -like 'Default') {
        $SetPSDrive = @{
            $InputDrive.Name = $InputDrive
        }
    }
    else {
        $members = $Json.PSDrive | Get-Member -MemberType NoteProperty
        foreach ($mem in $members) {
            $SetPSDrive += @{
                $mem.Name = $json.PSDrive.$($mem.Name)
            }
        }
        $SetPSDrive += @{
            $InputDrive.Name = $InputDrive
        }
    }

    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $SetPSDrive
        PSAlias     = $Json.PSAlias
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'PSDrive added'
        Write-Output "ConfigFile: $($confile.FullName)"
    }
    catch { Write-Error "Error: `n $_" }
} #end Function

 
Export-ModuleMember -Function Add-PSDriveToPSConfigFile
#endregion
 
#region Add-VariableToPSConfigFile.ps1
######## Function 7 of 15 ##################
# Function:         Add-VariableToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:07:52
# Synopsis:         Adds variable to the config file.
#############################################
 
<#
.SYNOPSIS
Adds variable to the config file.

.DESCRIPTION
Adds variable to the config file.

.PARAMETER VariableNames
The name of the variable. (Needs to exist already)

.EXAMPLE
Add-VariableToPSConfigFile -VariableNames AzureToken

#>
Function Add-VariableToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile')]
    PARAM(
        [ValidateScript( { ( Get-Variable $_) })]
        [string[]]$VariableNames
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add variable $($VariableNames)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    foreach ($VariableName in $VariableNames) {
        $Update = @()
        $SetVariable = @{}
        $InputVar = Get-Variable -Name $VariableName
        $inputtype = $InputVar.Value.GetType()
        if ($inputtype.Name -like 'PSCredential' -or $inputtype.Name -like 'SecureString') { Write-Error 'PSCredential or SecureString not allowed'; break }

        if ($Json.SetVariable.psobject.Properties.name -like 'Default' -and
            $Json.SetVariable.psobject.Properties.value -like 'Default') {
            $SetVariable = @{
                $InputVar.Name = $InputVar.Value
            }
        } else {
            $members = $Json.SetVariable | Get-Member -MemberType NoteProperty
            foreach ($mem in $members) {
                $SetVariable += @{
                    $mem.Name = $json.SetVariable.$($mem.Name)
                }
            }
            $SetVariable += @{
                $InputVar.Name = $InputVar.Value
            }
        }

        $Update = [psobject]@{
            Userdata    = $Userdata
            PSDrive     = $Json.PSDrive
            PSAlias     = $Json.PSAlias
            PSCreds     = $Json.PSCreds
            PSDefaults  = $Json.PSDefaults
            SetLocation = $Json.SetLocation
            SetVariable = $SetVariable
            Execute     = $Json.Execute
        }
        try {
            $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
            Write-Output 'Variable added'
            Write-Output "ConfigFile: $($confile.FullName)"
        } catch { Write-Error "Error: `n $_" }
    }
} #end Function


$scriptblock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-Variable | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object {"$($_.name)"}  
}
Register-ArgumentCompleter -CommandName Add-VariableToPSConfigFile -ParameterName VariableNames -ScriptBlock $scriptBlock
 
Export-ModuleMember -Function Add-VariableToPSConfigFile
#endregion
 
#region Export-PSConfigFilePFX.ps1
######## Function 8 of 15 ##################
# Function:         Export-PSConfigFilePFX
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/18 09:33:12
# ModifiedOn:       2022/08/18 09:47:52
# Synopsis:         Export the PFX file for credentials.
#############################################
 
<#
.SYNOPSIS
Export the PFX file for credentials.

.DESCRIPTION
Export the PFX file for credentials.

.PARAMETER Path
Path where the pfx will be saved.

.PARAMETER Credential
Credential used to export the pfx file.

.EXAMPLE
Export-PSConfigFilePFX -Path C:\temp -Credential $creds

#>
Function Export-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(Mandatory)]
		[System.IO.DirectoryInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName PFXExport -Message 'For the exported pfx file')
	)

	$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	if (-not($selfcert)) { Write-Error 'Certificate does not exist, nothing to export'}
	else {
		if (Test-Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')) {
			Rename-Item -Path (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"
		}
		$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $Credential.Password -FilePath (Join-Path -Path $ExportPath -ChildPath '\PSConfigFileCert.pfx')
	}

} #end Function
 
Export-ModuleMember -Function Export-PSConfigFilePFX
#endregion
 
#region Import-PSConfigFilePFX.ps1
######## Function 9 of 15 ##################
# Function:         Import-PSConfigFilePFX
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/18 09:38:48
# ModifiedOn:       2022/08/18 09:45:44
# Synopsis:         Import the PFX file for credentials
#############################################
 
<#
.SYNOPSIS
Import the PFX file for credentials

.DESCRIPTION
Import the PFX file for credentials

.PARAMETER Path
Path to the PFX file.

.PARAMETER Credential
Credential used to create the pfx file.

.EXAMPLE
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds

#>
Function Import-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[ValidateScript( { if ((Get-Item $_).Extension -like '.pfx') { $true }
				else {throw 'Not a valid .pfx file'}	
			})]
		[System.IO.FileInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName InportPFX -Message 'For the imported pfx file')	
	)

	Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}
	Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $PFXFilePath -Password $Credential.Password 

} #end Function
 
Export-ModuleMember -Function Import-PSConfigFilePFX
#endregion
 
#region Invoke-PSConfigFile.ps1
######## Function 10 of 15 ##################
# Function:         Invoke-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 10:10:04
# Synopsis:         Executes the config from the json file.
#############################################
 
<#
.SYNOPSIS
Executes the config from the json file.

.DESCRIPTION
Executes the config from the json file.

.PARAMETER ConfigFile
Path to the the config file that was created by New-PSConfigFile

.PARAMETER DisplayOutput
By default no output is displayed, switch this on to display the output. Or use Show-PSConfigFile to display the last execution.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSCustomConfig.json

#>
Function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

    #region import file
    try {
        $confile = Get-Item $ConfigFile -ErrorAction Stop
        $Script:PSConfigFileOutput = [System.Collections.Generic.List[string]]::new()
        $PSConfigFileOutput.Add('')

        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
        $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
        if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
        $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)")
    } catch {Write-Warning "Error Import: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Import: Message:$($_.Exception.Message)") }
    #endregion

    #region User Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:")
        $JSONParameter.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region User Data Modified
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Config File Modified Data:")
        $JSONParameter.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Variables
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:")
        $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            try {
                New-Variable -Name $_.name -Value $_.value -Force -Scope global -ErrorAction Stop
            } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
        }
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
        $PSConfigFileOutput.Add($output)
        New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force -ErrorAction Stop
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
        $PSConfigFileOutput.Add($output)
        New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force -ErrorAction Stop
    } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}

    #endregion

    #region Set PsDrives
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
        $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value.root)
            $PSConfigFileOutput.Add($output)
            if (-not(Get-PSDrive -Name $_.name -ErrorAction SilentlyContinue)) {
                New-PSDrive -Name $_.name -PSProvider FileSystem -Root $_.value.root -Scope Global | Out-Null
            } else { Write-Warning 'Warning: PSDrive - Already exists'; $PSConfigFileOutput.Add('<w>Warning: PSDrive - Already exists') }
        }
    } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Alias
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: ")
        $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            $command = "function global:$($_.name) {$($_.value)}"
            $tmp = [scriptblock]::Create($command)
            $tmp.invoke()
        }
    } catch {Write-Warning "Error Alias: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Alias: Message:$($_.Exception.Message)")}
    #endregion

    #region Creds
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
        if (-not([string]::IsNullOrEmpty($JSONParameter.PSCreds[0]))) {
            foreach ($Cred in ($JSONParameter.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"})) {
                $selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction Stop
                if ($selfcert.NotAfter -lt (Get-Date)) {
                    Write-Error "User Certificate not found.`nOr has expired"; $PSConfigFileOutput.Add('<e>Error Credentials: Message: User Certificate not found. Or has expired')
                } else {
                    $credname = $Cred.Name
                    $username = $Cred.UserName
                    $password = $Cred.EncryptedPwd
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($credname), "(PS$($PSVersionTable.PSEdition)) $($username)"
                    $PSConfigFileOutput.Add($output)
                    $EncryptedBytes = [System.Convert]::FromBase64String($password)
                    if ($PSVersionTable.PSEdition -like 'Desktop') {
                        try {
                            $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, $true)
                        } catch {Write-Warning "Error Credentials: `n`tMessage: Password was encoded in PowerShell Core"; $PSConfigFileOutput.Add('<e>Error Credentials: Message: Password was encoded in PowerShell Core')}
                    } else {
                        try {
                            $DecryptedBytes = $selfcert.PrivateKey.Decrypt($EncryptedBytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
                        } catch {Write-Warning "Error Credentials: `n`tMessage: Password was encoded in PowerShell Desktop"; $PSConfigFileOutput.Add('<e>Error Credentials: Message:  Password was encoded in PowerShell Desktop')}
                    }
                    try {
                        $DecryptedPwd = [system.text.encoding]::UTF8.GetString($DecryptedBytes) | ConvertTo-SecureString -AsPlainText -Force
                        New-Variable -Name $Credname -Value (New-Object System.Management.Automation.PSCredential ($username, $DecryptedPwd)) -Scope Global -Force -ErrorAction Stop
                    } catch {Write-Warning "Error Credentials: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Credentials: Message:$($_.Exception.Message)")}
                }
            }
        }
    } catch {Write-Warning "Error Credentials: `n`tMessage:$($_.Exception.Message)"}
    #endregion

    #region Set PSDefaults
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting PSDefaults:")
        foreach ($PSD in  ($JSONParameter.PSDefaults | Where-Object {$_ -notlike $null})) {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($PSD.Name.Split(':')[0]), $($PSD.Name.Split(':')[1]), $($PSD.Value)
            $PSConfigFileOutput.Add($output)
            $PSDefaultParameterValues.Remove($PSD.Name)
            $PSDefaultParameterValues.Add($PSD.Name, $PSD.Value)
        }
    } catch {Write-Warning "Error PSDefaults $($PSD.Name): `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDefaults $($PSD.Name): Message:$($_.Exception.Message)")}
    #endregion

    #region Set Location
    try {
        if ($null -notlike $JSONParameter.SetLocation) {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($JSONParameter.SetLocation.WorkerDir))
            $PSConfigFileOutput.Add($output)
            if ([bool](Get-PSDrive $($JSONParameter.SetLocation.WorkerDir) -ErrorAction SilentlyContinue)) { Set-Location -Path "$($JSONParameter.SetLocation.WorkerDir):" }
            elseif (Test-Path $($JSONParameter.SetLocation.WorkerDir)) { Set-Location $($JSONParameter.SetLocation.WorkerDir) }
            else { Write-Error '<e>No valid location found.' }
        }
    } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
    #endregion

    #region Execute Commands
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: ")
        $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
            $tmp = $null
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
            $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())]  ScriptBlock Output:")
            $tmp = [scriptblock]::Create($_.value)
            $tmp.invoke()
        }
    } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
    #endregion

    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End")

    if ($DisplayOutput) {
        foreach ($line in $PSConfigFileOutput) {
            if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
            if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
            if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
            if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
        }
    } else {
        Write-Host '[Completed]' -NoNewline -ForegroundColor Yellow; Write-Host ' Invoke-PSConfigFile ' -ForegroundColor Cyan
        Write-Host '[ConfigFile]: ' -ForegroundColor Yellow -NoNewline; Write-Host "$ConfigFile" -ForegroundColor DarkRed
    }
    
} #end Function
 
Export-ModuleMember -Function Invoke-PSConfigFile
#endregion
 
#region New-PSConfigFile.ps1
######## Function 11 of 15 ##################
# Function:         New-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 08:01:05
# Synopsis:         Creates a new config file
#############################################
 
<#
.SYNOPSIS
Creates a new config file

.DESCRIPTION
Creates a new config file. If a config file already exists in that folder, it will be renamed.

.PARAMETER ConfigDir
Directory to create config file

.EXAMPLE
 New-PSConfigFile -ConfigDir C:\Temp\config

#>
Function New-PSConfigFile {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_) {$true}
                         else {new-item -Path $_ -ItemType Directory -Force |out-null }
        })]
        [System.IO.DirectoryInfo]$ConfigDir
    )

    function DafaultSettings {
        try {
            $Userdata = New-Object PSObject -Property @{
                Owner             = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
                CreatedOn         = (Get-Date -Format u)
                PSExecutionPolicy = $env:PSExecutionPolicyPreference
                Path              = "$((Join-Path (Get-Item $ConfigDir).FullName -ChildPath \PSCustomConfig.json))"
                Hostname          = (([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName).ToLower()
                PSEdition         = "$($PSVersionTable.PSEdition) (ver $($PSVersionTable.PSVersion.ToString()))"
                OS                = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
                PSConfigFileVer   = (Get-Module PSConfigFile | Sort-Object -Property Version)[0].Version.ToString()
                ModifiedData      = [PSCustomObject]@{
                    ModifiedDate   = 'None'
                    ModifiedUser   = 'None'
                    ModifiedAction = 'None'
                    Path           = 'None'
                    Hostname       = 'None'
                }
            }
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
        
        $SetLocation = New-Object PSObject -Property @{}
        $SetVariable = New-Object PSObject -Property @{
            Default = 'Default'
        }
        $Execute = New-Object PSObject -Property @{
            Default = 'Default'
        }
        $PSDrive = New-Object PSObject -Property @{
            Default = 'Default'
        }
        $PSAlias = New-Object PSObject -Property @{
            Default = 'Default'
        }
        $PSCreds = New-Object PSObject -Property @{
            Default = 'Default'
        }
        $PSDefaults = New-Object PSObject -Property @{
            Default = 'Default'
        }   
        #main
        New-Object PSObject -Property @{
            Userdata    = $Userdata
            PSDrive     = $PSDrive
            PSAlias     = $PSAlias
            PSCreds     = $PSCreds
            PSDefaults  = $PSDefaults
            SetLocation = $SetLocation
            SetVariable = $SetVariable
            Execute     = $Execute
        }

    }

    $Fullpath = Get-Item $ConfigDir
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
        $check = Test-Path -Path (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -ErrorAction SilentlyContinue
        if (-not($check)) {
            Write-Output 'Config File does not exit, creating default settings.'

            $data = DafaultSettings
            $data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Force
            Write-Host "[Created] " -ForegroundColor Yellow -NoNewline; Write-Host "$((Join-Path $Fullpath -ChildPath \PSCustomConfig.json))" -ForegroundColor DarkRed
        } else {

            Write-Warning "ConfigFile exists, renaming file now to:`n`nPSCustomConfig_$(Get-Date -Format ddMMyyyy_HHmm).json"
            Rename-Item (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -NewName "PSCustomConfig_$(Get-Date -Format ddMMyyyy_HHmm).json"

            $data = DafaultSettings
            $data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Force
           Write-Host "[Created] " -ForegroundColor Yellow -NoNewline; Write-Host "$((Join-Path $Fullpath -ChildPath \PSCustomConfig.json))" -ForegroundColor DarkRed
        }
    }
    Invoke-PSConfigFile -ConfigFile (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -DisplayOutput
}
 
Export-ModuleMember -Function New-PSConfigFile
#endregion
 
#region Remove-ConfigFromPSConfigFile.ps1
######## Function 12 of 15 ##################
# Function:         Remove-ConfigFromPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/22 07:47:34
# ModifiedOn:       2022/08/18 08:52:28
# Synopsis:         Removes a item from the config file.
#############################################
 
<#
.SYNOPSIS
Removes a item from the config file.

.DESCRIPTION
Removes a item from the config file.

.PARAMETER Variable
Name of the variable to remove.

.PARAMETER PSDrive
Name of the PSDrive to remove.

.PARAMETER PSAlias
Name of the Alias to remove.

.PARAMETER Command
Name of the Command to remove.

.PARAMETER CredentialName
Name of the Credential to remove.

.PARAMETER Location
Set Location to blank again.

.EXAMPLE
Remove-ConfigFromPSConfigFile -PSDrive ProdMods

#>
<#
.SYNOPSIS
Removes a item from the config file.

.DESCRIPTION
Removes a item from the config file.

.PARAMETER Config
Which config item to remove.

.PARAMETER Value
The value of the config item to filter

.EXAMPLE
Remove-ConfigFromPSConfigFile -Config PSDrive -Value ProdMods

#>
Function Remove-ConfigFromPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
    PARAM(
        [ValidateSet('Variable', 'PSDrive', 'Alias', 'Command', 'Credential', 'PSDefaults', 'Location')]
        [string]$Config,
        [string]$Value
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    [System.Collections.Generic.List[pscustomobject]]$JsonConfig = @()
    $JsonConfig.Add((Get-Content $confile.FullName | ConvertFrom-Json))
    $userdataModAction = "Removed Config:`n"

    if ($Config -like "Variable") {
        $userdataModAction += "Remove Variable $($Value)`n"
        $JsonConfig.SetVariable.PSObject.properties | Where-Object {$_.name -notlike "*$Value*"} | ForEach-Object {$SetVariable += @{$_.name = $_.value}}
    } else {$SetVariable = $JsonConfig.setvariable}

    if ($Config -like "PSDrive") {
        $userdataModAction += "Remove PSDrive $($Value)`n"
        $JsonConfig.PSDrive.PSObject.properties | Where-Object {$_.name -notlike "*$Value*"} | ForEach-Object {$SetPSDrive += @{$_.name = $_.value}}
    } else {$SetPSDrive = $JsonConfig.PSDrive}

    if ($Config -like "Alias") {
        $userdataModAction += "Remove Alias $($Value)`n"
        $JsonConfig.PSAlias.PSObject.Properties | Where-Object {$_.name -notlike "*$Value*"} | ForEach-Object {$SetPSAlias += @{$_.name = $_.value}}
    } else {$SetPSAlias = $JsonConfig.PSAlias}

    if ($Config -like "Command") { 
        $userdataModAction += "Remove Command $($Value)`n"
        $JsonConfig.Execute.PSObject.Properties | Where-Object {$_.name -notlike "*$Value*"} | ForEach-Object {$SetExecute += @{$_.name = $_.value}}
    } else {$SetExecute = $JsonConfig.Execute}

    if ($Config -like "Credential") {
        $userdataModAction += "Remove Credential $($Value)`n"
        $SetCreds = $JsonConfig.PSCreds | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetCreds = $JsonConfig.PSCreds}

    if ($Config -like "PSDefaults") {
        $userdataModAction += "Remove PSDefaults $($Value)`n"
        $SetPSDefaults = $JsonConfig.PSDefaults | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSDefaults = $JsonConfig.PSDefaults}

    if ($Config -like 'Location') {
        $userdataModAction += "Remove Location`n"
        $SetLocation = @{}
    } else {$SetLocation = $JsonConfig.SetLocation}
    
    $userdata = [PSCustomObject]@{
        Owner             = $JsonConfig.Userdata.Owner
        CreatedOn         = $JsonConfig.Userdata.CreatedOn
        PSExecutionPolicy = $JsonConfig.Userdata.PSExecutionPolicy
        Path              = $JsonConfig.Userdata.Path
        Hostname          = $JsonConfig.Userdata.Hostname
        PSEdition         = $JsonConfig.Userdata.PSEdition
        OS                = $JsonConfig.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = ($userdataModAction | Out-String).Trim()
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }
    $Update = @()
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $SetPSDrive
        PSAlias     = $SetPSAlias
        PSCreds     = $SetCreds
        PSDefaults  = $SetPSDefaults
        SetLocation = $SetLocation
        SetVariable = $SetVariable
        Execute     = $SetExecute
    }
    try {
        $Update | ConvertTo-Json | Set-Content -Path $confile.FullName -Force
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function
 
Export-ModuleMember -Function Remove-ConfigFromPSConfigFile
#endregion
 
#region Set-PSConfigFileExecution.ps1
######## Function 13 of 15 ##################
# Function:         Set-PSConfigFileExecution
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/03/23 13:01:33
# Synopsis:         Adds functionality to add the execution to your profile or a PowerShell module
#############################################
 
<#
.SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

.PARAMETER PSProfile
Enable or disable loading of config when your ps profile is loaded.

.PARAMETER PSModule
Enable or disable loading of config when a specific module is loaded.

.PARAMETER ModuleName
Name of the module to be updated.
If the module is not in the standard folders ($env:PSModulePath), then import it into your session first.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile AddScript -PSModule AddScript -ModuleName LabScripts

#>
Function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSModule = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [ValidateScript( {
                $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -and ([bool](Get-Module $_) -or ([bool](Get-Module $_ -ListAvailable)))) { $True }
                else { Throw 'Invalid Module name and you must be running an elevated prompt to use this fuction.' } })]
        [string]$ModuleName
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        $string = @"
#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile
"@

        if ($PSModule -like 'AddScript') {
            try {
                $ModModules = Get-Module $ModuleName
                if (-not($ModModules)) { $ModModules = Get-Module $ModuleName -ListAvailable }
                if (-not($ModModules)) { throw 'Module not found' }

                foreach ($ModModule in $ModModules) {

                    if (-not(Test-Path -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile'))) { $PSConfigFilePath = New-Item -Path $ModModule.ModuleBase -Name PSConfigFile -ItemType Directory }
                    else { $PSConfigFilePath = Get-Item (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile') }

                    if (-not(Test-Path (Join-Path $PSConfigFilePath.FullName -ChildPath 'PSConfigFile_ScriptToProcess.ps1'))) {
                        $string | Set-Content -Path (Join-Path $PSConfigFilePath.FullName -ChildPath 'PSConfigFile_ScriptToProcess.ps1') -Force
                    }

                    $ModModuleManifest = Test-ModuleManifest -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath "\$($ModModule.Name).psd1")
                    [System.Collections.ArrayList]$newScriptsToProcess = @()
                    foreach ($Scripts in $ModModuleManifest.Scripts) {
                        $ScriptPath = Get-Item $Scripts
                        [void]$newScriptsToProcess.Add("$(($ScriptPath.Directory).Name)\$($ScriptPath.Name)")
                    }


                    [void]$newScriptsToProcess.Add('PSConfigFile\PSConfigFile_ScriptToProcess.ps1')
                    Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess $newScriptsToProcess
                    Write-Color '[Updated]', 'Modulename: ', $ModuleName -Color Cyan, Gray, Yellow
                }
            }
            catch { Write-Error "Unable to update Module Manifest: `n $_" }

        }
        if ($PSModule -like 'RemoveScript') {
            try {
                $ModModules = Get-Module $ModuleName
                if (-not($ModModules)) { $ModModules = Get-Module $ModuleName -ListAvailable }
                if (-not($ModModules)) { throw 'Module not found' }

                foreach ($ModModule in $ModModules) {
                    $ModModuleManifest = Test-ModuleManifest -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath "\$($ModModule.Name).psd1")
                    [System.Collections.ArrayList]$newScriptsToProcess = @()
                    foreach ($Scripts in ($ModModuleManifest.Scripts | Where-Object { $_ -notlike '*PSConfigFile*' })) {
                        $ScriptPath = Get-Item $Scripts
                        [void]$newScriptsToProcess.Add("$(($ScriptPath.Directory).Name)\$($ScriptPath.Name)")
                    }

                    if ($null -like $newScriptsToProcess ) {
                        $null = New-Item -Path $ModModule.ModuleBase -Name 'empty.ps1' -ItemType File -Value '# Because Update-ModuleManifest cant have empty ScriptsToProcess values'
                        Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess 'empty.ps1'
                    }
                    else {
                        Update-ModuleManifest -Path $ModModuleManifest.Path -ScriptsToProcess $newScriptsToProcess
                    }
                    if (Test-Path -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile')) { Remove-Item -Path (Join-Path -Path $ModModule.ModuleBase -ChildPath '\PSConfigFile') -Recurse -Force }
                    Write-Color '[Removed]', 'Modulename: ', $ModuleName -Color Cyan, Gray, Yellow
                }
            }
            catch { Write-Error "Unable to update Module Manifest: `n $_" }
        }
        if ($PSProfile -like 'AddScript') {

            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ps
                Write-Color '[Updated]', 'Profile: ', $ps -Color Cyan, Gray, Yellow
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ise
                Write-Color '[Updated]', 'Profile: ', $ise -Color Cyan, Gray, Yellow
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $vs
                Write-Color '[Updated]', 'Profile: ', $vs -Color Cyan, Gray, Yellow
            }

        }
        if ($PSProfile -like 'RemoveScript') {
            if ((Test-Path (Get-Item $profile).DirectoryName) -eq $false ) {
                Write-Warning 'Profile does not exist, creating file.'
                New-Item -ItemType File -Path $Profile -Force
            }
            $psfolder = (Get-Item $profile).DirectoryName

            $ps = Join-Path $psfolder \Microsoft.PowerShell_profile.ps1
            $ise = Join-Path $psfolder \Microsoft.PowerShellISE_profile.ps1
            $vs = Join-Path $psfolder \Microsoft.VSCode_profile.ps1

            if (Test-Path $ps) {
                $ori = Get-Content $ps | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ps
                Write-Color '[Removed]', 'Profile: ', $ps -Color Cyan, Gray, Yellow
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ise
                Write-Color '[Removed]', 'Profile: ', $ise -Color Cyan, Gray, Yellow
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $vs
                Write-Color '[Removed]', 'Profile: ', $vs -Color Cyan, Gray, Yellow
            }


        }
    }
} #end Function

 
Export-ModuleMember -Function Set-PSConfigFileExecution
#endregion
 
#region Show-PSConfigFile.ps1
######## Function 14 of 15 ##################
# Function:         Show-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:05
# ModifiedOn:       2022/08/18 09:53:55
# Synopsis:         Display what's configured in the config file.
#############################################
 
<#
.SYNOPSIS
Display what's configured in the config file.

.DESCRIPTION
Display what's configured in the config file. But doesn't execute the commands

.PARAMETER ShowLastInvokeOutput
Display the output of the last Invoke-PSConfigFile execution.

.PARAMETER OtherConfigFile
Path to a previously created config file.

.EXAMPLE
Show-PSConfigFile -ShowLastInvokeOutput

#>
Function Show-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Show-PSConfigFile')]
    param (
        [switch]$ShowLastInvokeOutput,
        [System.IO.FileInfo]$OtherConfigFile
    )

    if ($ShowLastInvokeOutput) { $outputfile = $PSConfigFileOutput }
    else {
        try {
            if ([string]::IsNullOrEmpty($OtherConfigFile)) {
                Add-Type -AssemblyName System.Windows.Forms
                $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
                $null = $FileBrowser.ShowDialog()
                $confile = Get-Item $FileBrowser.FileName
            } else {
                try {
                    $confile = Get-Item $OtherConfigFile -ErrorAction stop
                } catch {
                    Add-Type -AssemblyName System.Windows.Forms
                    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
                    $null = $FileBrowser.ShowDialog()
                    $confile = Get-Item $FileBrowser.FileName
                }
            }

            $outputfile = [System.Collections.Generic.List[string]]::new()
            $outputfile.Add('')

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
            if ([string]::IsNullOrEmpty($JSONParameter)) { Write-Error 'Valid Parameters file not found'; break }
            $outputfile.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)")

            #region User Data
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:")
            $JSONParameter.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            #endregion

            #region User Data Modified
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Config File Modified Data:")
            $JSONParameter.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            #endregion

            #Set Variables
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:")
            $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            $PSConfigFilePathoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $outputfile.Add($PSConfigFilePathoutput)
            $PSConfigFileoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $outputfile.Add($PSConfigFileoutput)

            # Set PsDrives
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
            $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value.root)
                $outputfile.Add($output)
            }

            # Set Alias
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: ")
            $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }

            #region Creds
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
            if (-not([string]::IsNullOrEmpty($JSONParameter.PSCreds[0]))) {
                foreach ($Cred in ($JSONParameter.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"})) {
                    $credname = $Cred.Name
                    $username = $Cred.UserName
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($credname), "(PS$($PSVersionTable.PSEdition)) $($username)"
                    $outputfile.Add($output)
                }
            }
            #endregion

            #region Set PSDefaults
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting PSDefaults:")
            foreach ($PSD in  $JSONParameter.PSDefaults) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($PSD.Name.Split(':')[0]), $($PSD.Name.Split(':')[1]), $($PSD.Value)
                $outputfile.Add($output)
            }
            #endregion

            # Execute Commands
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: ")
            $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }

            # Set Location
            if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($JSONParameter.SetLocation.WorkerDir))
                $outputfile.Add($output)
            }

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End")
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
    }

    foreach ($line in $outputfile) {
        if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
        if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
        if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
        if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
    }

} #end Function
 
Export-ModuleMember -Function Show-PSConfigFile
#endregion
 
#region Update-CredentialsInPSConfigFile.ps1
######## Function 15 of 15 ##################
# Function:         Update-CredentialsInPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.35
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/07/28 20:29:29
# ModifiedOn:       2022/08/18 10:04:39
# Synopsis:         Allows you to renew the certificate or saved passwords.
#############################################
 
<#
.SYNOPSIS
Allows you to renew the certificate or saved passwords.

.DESCRIPTION
Allows you to renew the certificate or saved passwords.

.PARAMETER RenewSelfSignedCert
Creates a new self signed certificate, and re-encrypts the passwords.

.PARAMETER RenewSavedPasswords
Re-encrypts the passwords for the current PS Edition. Run it in PS core and desktop to save both version.

.EXAMPLE
Update-CredentialsInPSConfigFile -RenewSavedPasswords All

#>
Function Update-CredentialsInPSConfigFile {
	[Cmdletbinding(DefaultParameterSetName = 'Renew', HelpURI = 'https://smitpi.github.io/PSConfigFile/Update-CredentialsInPSConfigFile')]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
	PARAM(
		[Parameter(ParameterSetName = 'Renew')]
		[switch]$RenewSelfSignedCert,

		[Parameter(ParameterSetName = 'Renew')]
		[string[]]$RenewSavedPasswords
	)

 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
	$userdata = [PSCustomObject]@{
		Owner             = $json.Userdata.Owner
		CreatedOn         = $json.Userdata.CreatedOn
		PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
		Path              = $json.Userdata.Path
		Hostname          = $json.Userdata.Hostname
		PSEdition         = $json.Userdata.PSEdition
		OS                = $json.Userdata.OS
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = (Get-Date -Format u)
			ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			ModifiedAction = 'Modified Credentials'
			Path           = "$confile"
			Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
		}
	}

	function RedoPass {
		PARAM([string]$RenewSavedPasswords)

		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update = @()
		[System.Collections.ArrayList]$RenewCreds = @()

		foreach ($OtherCred in ($Json.PSCreds | Where-Object {$_.Edition -notlike "*$($PSVersionTable.PSEdition)*"})) {
			[void]$RenewCreds.Add($OtherCred)
		}
        
		$UniqueCreds = $Json.PSCreds | Sort-Object -Property Name -Unique
		if ($RenewSavedPasswords -like 'All') {$renew = $UniqueCreds}
		else {
			$renew = $UniqueCreds | Where-Object {$_.name -in $RenewSavedPasswords}
			$UniqueCreds | Where-Object {$_.name -notin $RenewSavedPasswords} | ForEach-Object {[void]$RenewCreds.Add($_)}
		}

		foreach ($cred in $renew) {
			$tmpcred = Get-Credential -UserName $cred.UserName -Message 'Renew Password'
			$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
			$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
			$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
			if ($PSVersionTable.PSEdition -like 'Desktop') {
				$Edition = 'PSDesktop'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, $true)
			} else {
				$Edition = 'PSCore'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
			}
			$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
			[void]$RenewCreds.Add([PSCustomObject]@{
					Name         = $cred.name
					Edition      = $Edition
					UserName     = $cred.UserName
					EncryptedPwd = $EncryptedPwd
				})
		}
		$Update = [psobject]@{
			Userdata    = $Userdata
			PSDrive     = $Json.PSDrive
			PSAlias     = $Json.PSAlias
			PSCreds     = $RenewCreds
			PSDefaults  = $Json.PSDefaults
			SetLocation = $Json.SetLocation
			SetVariable = $Json.SetVariable
			Execute     = $Json.Execute
		}
		try {
			$Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
			Write-Output 'Credentials Updated'
			Write-Output "ConfigFile: $($confile.FullName)"
		} catch { Write-Error "Error: `n $_" }
	}

	if ($RenewSelfSignedCert) { 
		Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}
		$SelfSignedCertParams = @{
			DnsName           = 'PSConfigFileCert'
			KeyDescription    = 'PowerShell Credencial Encryption-Decryption Key'
			Provider          = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
			KeyFriendlyName   = 'PSConfigFileCert'
			FriendlyName      = 'PSConfigFileCert'
			Subject           = 'PSConfigFileCert'
			KeyUsage          = 'DataEncipherment'
			Type              = 'DocumentEncryptionCert'
			HashAlgorithm     = 'sha256'
			CertStoreLocation = 'Cert:\\CurrentUser\\My'
			NotAfter          = (Get-Date).AddMonths(2)
			KeyExportPolicy   = 'Exportable'
		} # end params
		New-SelfSignedCertificate @SelfSignedCertParams | Out-Null
		RedoPass -RenewSavedPasswords All
	} 
	if (-not([string]::IsNullOrEmpty($RenewSavedPasswords))) {RedoPass -RenewSavedPasswords $RenewSavedPasswords}

} #end Function


$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$var = @('All')
	$var += Get-Variable | Where-Object {$_.Name -like "$wordToComplete*" -and $_.value -like 'System.Management.Automation.PSCredential'} | ForEach-Object {"$($_.name)"}
	$var
	#Get-Variable | Where-Object {$_.value -like "System.Management.Automation.PSCredential"} | ForEach-Object {"$($_.name)"}
}
Register-ArgumentCompleter -CommandName Update-CredentialsInPSConfigFile -ParameterName RenewSavedPasswords -ScriptBlock $scriptBlock
 
Export-ModuleMember -Function Update-CredentialsInPSConfigFile
#endregion
 
#endregion
 
