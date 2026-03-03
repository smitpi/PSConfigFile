#region Public Functions
#region Add-CommandToPSConfigFile.ps1
######## Function 1 of 15 ##################
# Function:         Add-CommandToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:27 AM
# ModifiedOn:       3/3/2026 1:18:24 PM
# Synopsis:         Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.
#############################################
 
<#
.SYNOPSIS
Adds a named command or script block to the PSConfigFile configuration to be executed automatically when the config is invoked.

.DESCRIPTION
Use this function to store custom commands or script blocks in your configuration file. These commands will be executed every time the config file is invoked using Invoke-PSConfigFile. This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

.PARAMETER ScriptBlockName
The unique name to assign to the script block. This name is used to identify and manage the command within the config file.

.PARAMETER ScriptBlock
The PowerShell command(s) or script block to be executed. Provide as a string. Example: "Get-ChildItem C:\\Logs | Out-File C:\\log.txt"

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\\"
Adds a script block named 'DriveC' that lists the contents of the C drive every time the config is invoked.

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName Startup -ScriptBlock "Write-Host 'Welcome!'" -Force
Adds a script block named 'Startup' that displays a welcome message, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.
#>
function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock,
        [switch]$Force
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }

    $XMLData = Import-Clixml -Path $confile.FullName

    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Added Command: $($ScriptBlockName)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$ExecuteObject = @()
    
    if ([string]::IsNullOrEmpty($XMLData.Execute)) {
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = 0
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    } else {
        $XMLData.Execute | Where-Object {$_.Name -notlike $ScriptBlockName} | ForEach-Object {$ExecuteObject.Add($_)}
        $IndexID = $ExecuteObject.IndexID | Sort-Object -Descending | Select-Object -First 1
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = ($IndexID + 1 )
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    }
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = ($ExecuteObject | Where-Object {$_ -notlike $null})
    }
    try {
        if ($force) {
            Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
            Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
        } else {
            Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
            Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
        }
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'Command Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($ScriptBlockName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function
 
Export-ModuleMember -Function Add-CommandToPSConfigFile
#endregion
 
#region Add-CredentialToPSConfigFile.ps1
######## Function 2 of 15 ##################
# Function:         Add-CredentialToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:23 AM
# ModifiedOn:       3/3/2026 1:07:16 PM
# Synopsis:         Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.
#############################################
 
<#
.SYNOPSIS
Securely saves a credential to the PSConfigFile configuration using a self-signed certificate for encryption.

.DESCRIPTION
Use this function to securely store a PowerShell credential object in your configuration file. A self-signed certificate is created (if one does not already exist) and used to encrypt the credential. The certificate can be exported and installed on other machines, allowing you to decrypt and use the credential securely across trusted systems. This is ideal for automating scripts that require credentials without exposing sensitive information in plain text.

.PARAMETER Name
The unique variable name to assign to the credential in the config file. This name is used to reference the credential when invoking commands from the config.

.PARAMETER Credential
The PowerShell credential object to be securely stored. Use Get-Credential to create this object first.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
$labcred = Get-Credential
Add-CredentialToPSConfigFile -Name LabTest -Credential $labcred
Prompts for credentials and saves them securely in the config file under the name 'LabTest'.

.EXAMPLE
Add-CredentialToPSConfigFile -Name AdminUser -Credential (Get-Credential) -Force
Saves a credential named 'AdminUser', overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Credentials are encrypted using a self-signed certificate for security and portability.
#>
function Add-CredentialToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CredentialToPSConfigFile')]
	[OutputType([System.Object[]])]
	param(
		[string]$Name,
		[string]$Credential,
		[switch]$Force
	)

 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$XMLData = Import-Clixml -Path $confile.FullName
	$userdata = [PSCustomObject]@{
		Owner             = $XMLData.Userdata.Owner
		CreatedOn         = $XMLData.Userdata.CreatedOn
		PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
		Path              = $XMLData.Userdata.Path
		Hostname          = $XMLData.Userdata.Hostname
		PSEdition         = $XMLData.Userdata.PSEdition
		OS                = $XMLData.Userdata.OS
		BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = [datetime](Get-Date)
			ModifiedAction = "Added Credencial: $($Name)"
		}
	}
	[pscredential]$FindCred = (Get-Variable -Name "$($Credential)").Value

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

	$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($FindCred.Password)
	$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
	[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
	if ($PSVersionTable.PSEdition -eq 'PSDesktop') {
		Write-Error 'Credentials is only a feature of Powershell core.'
		return
	} else {
		$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
		$Edition = 'PSCore'
		$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
		$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
	}
	
	$Update = @()
	[System.Collections.ArrayList]$SetCreds = @()
		
	if ([string]::IsNullOrEmpty($XMLData.PSCreds)) {
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $FindCred.UserName
				EncryptedPwd = $EncryptedPwd
			})
	} else {
		$XMLData.PSCreds | Where-Object {$_.Name -notlike $Name} | ForEach-Object {[void]$SetCreds.Add($_)}
		[void]$SetCreds.Add([PSCustomObject]@{
				Name         = $Name
				Edition      = $Edition
				UserName     = $FindCred.UserName
				EncryptedPwd = $EncryptedPwd
			})
	}

	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $XMLData.PSDrive
		PSFunction  = $XMLData.PSFunction
		PSCreds     = ($SetCreds | Where-Object {$_ -notlike $null} | Sort-Object -Property Name)
		PSDefaults  = $XMLData.PSDefaults
		SetLocation = $XMLData.SetLocation
		SetVariable = $XMLData.SetVariable
		Execute     = $XMLData.Execute
	}
	try {
		if ($force) {
			Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
			Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
		} else {
			Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
			Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
		}
		$Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
		Write-Host 'Credential Added: ' -ForegroundColor Green -NoNewline
		Write-Host "$($Name)" -ForegroundColor Yellow
		Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
	} catch { Write-Error "Error: `n $_" }
} #end Function

$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	Get-Variable | Where-Object {$_.Name -like "$wordToComplete*" -and $_.value -like 'System.Management.Automation.PSCredential'} | ForEach-Object {"$($_.name)"}
}
Register-ArgumentCompleter -CommandName Add-CredentialToPSConfigFile -ParameterName Credential -ScriptBlock $scriptBlock
 
Export-ModuleMember -Function Add-CredentialToPSConfigFile
#endregion
 
#region Add-FunctionToPSConfigFile.ps1
######## Function 3 of 15 ##################
# Function:         Add-FunctionToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:06 AM
# ModifiedOn:       3/3/2026 1:18:39 PM
# Synopsis:         Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Adds a named PowerShell function (shortcut) to the PSConfigFile configuration.

.DESCRIPTION
Use this function to define named PowerShell functions (shortcuts) that execute specific commands or script blocks. These functions are stored in your configuration file and can be invoked automatically or manually, streamlining repetitive tasks and environment setup. This is useful for automating environment setup, running startup tasks, or ensuring certain commands always run in your PowerShell environment.

.PARAMETER FunctionName
The unique name to assign to the custom function. This name is used to identify and manage the function within the config file.

.PARAMETER CommandToRun
The PowerShell command(s) or script block to be executed by the function. Provide as a string. Example: "Import-Module .\*.psm1 -Force -Verbose"

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName psml -CommandToRun "Import-Module .\*.psm1 -Force -Verbose"
Adds a function named 'psml' that imports all PowerShell modules in the current directory with force and verbose options.

.EXAMPLE
Add-FunctionToPSConfigFile -FunctionName CleanLogs -CommandToRun "Remove-Item C:\\Logs\\* -Recurse -Force" -Force
Adds a function named 'CleanLogs' to delete all log files, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation.
#>
function Add-FunctionToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-FunctionToPSConfigFile')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun,
        [switch]$Force
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }

    $XMLData = Import-Clixml -Path $confile.FullName
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Added Function: $($FunctionName)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$FunctionObject = @()
        
    if ([string]::IsNullOrEmpty($XMLData.PSFunction)) {
        $FunctionObject.Add([PSCustomObject]@{
                Name    = $FunctionName 
                Command = $CommandToRun
            })
    } else {
        $XMLData.PSFunction | Where-Object {$_.Name -notlike $FunctionName} | ForEach-Object {$FunctionObject.Add($_)}
        $FunctionObject.Add([PSCustomObject]@{
                Name    = $FunctionName 
                Command = $CommandToRun
            })
    }

    $Update = [psobject]@{
        Userdata    = $userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = ($FunctionObject | Where-Object {$_ -notlike $null})
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = $XMLData.Execute
    }
    try {
        if ($force) {
            Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
            Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
        } else {
            Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
            Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
        }
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'Function Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($FunctionName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function

 
Export-ModuleMember -Function Add-FunctionToPSConfigFile
#endregion
 
#region Add-LocationToPSConfigFile.ps1
######## Function 4 of 15 ##################
# Function:         Add-LocationToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:09 AM
# ModifiedOn:       3/3/2026 1:18:39 PM
# Synopsis:         Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

.DESCRIPTION
Use this function to specify a default working location for your PowerShell session, either as a folder path or a PSDrive. When the config file is invoked using Invoke-PSConfigFile, your session will automatically change to this location. This is useful for streamlining your workflow and ensuring you always start in the correct directory or drive.

.PARAMETER LocationType
Specifies the type of location to add. Accepts 'PSDrive' for a PowerShell drive or 'Folder' for a filesystem path.

.PARAMETER Path
The path to the folder or the name of the PSDrive to set as the default location. Must exist as a valid path or drive.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType PSDrive -Path temp
Sets the default location to the 'temp' PSDrive when the config is invoked.

.EXAMPLE
Add-LocationToPSConfigFile -LocationType Folder -Path c:\temp
Sets the default location to the 'c:\temp' folder when the config is invoked.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to ensure your PowerShell session always starts in the correct directory or drive.
#>

function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    param(
        [ValidateScript( {( [bool](Get-PSDrive $_)) })]
        [string]$PSDriveName,
        [ValidateScript( { ( Test-Path $_) })]
        [System.IO.DirectoryInfo]$FolderPath,
        [switch]$Force
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
   } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }
    if ((-not($PSBoundParameters.ContainsKey('PSDriveName'))) -and (-not($PSBoundParameters.ContainsKey('FolderPath')))) {
        Write-Error 'Parameters are emty'
    }
    if ($PSBoundParameters.ContainsKey('PSDriveName')) {
        try {
            $Drive = Get-PSDrive $PSDriveName -ErrorAction Stop
            $PathName = $Drive.Name
            $PathValue = $Drive.Root
            $PathType = 'PSDrive'
        } catch {
            Write-Error "PSDrive: Error: `n $_"
        }
    }
    if ($PSBoundParameters.ContainsKey('FolderPath')) {
        try {
            $PathName = $FolderPath.Name
            $PathValue = $FolderPath.FullName
            $PathType = 'Folder'
        } catch {
            Write-Error "Folder: Error: `n $_"
        }

    }
    $Update = @()
    [System.Collections.generic.List[PSObject]]$SetLocation = @()
    $SetLocation.Add([PSCustomObject]@{
            Name  = $PathName
            value = $PathValue
            Type  = $PathType
        })

    $XMLData = Import-Clixml -Path $confile.FullName
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Working Directory Changed: $($PathName)"
        }
    }


    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $XMLData.PSDrive
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = $XMLData.Execute
    }
    try {
        if ($force) {
            Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
            Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
        } else {
            Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
            Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
        }
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'Working Directory Changed: ' -ForegroundColor Green -NoNewline
        Write-Host "$($PathName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }


} #end Function
 
Export-ModuleMember -Function Add-LocationToPSConfigFile
#endregion
 
#region Add-PSDefaultParameterToPSConfigFile.ps1
######## Function 5 of 15 ##################
# Function:         Add-PSDefaultParameterToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:24 AM
# ModifiedOn:       3/3/2026 1:02:28 PM
# Synopsis:         Adds a default parameter value for a function to the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Adds a default parameter value for a function to the PSConfigFile configuration.

.DESCRIPTION
This function allows you to specify default parameter values for any PowerShell function. These defaults are stored in your configuration file and will be automatically applied in your session, saving you from repeatedly specifying common parameters. Wildcards can be used to apply defaults to multiple functions or parameters.

.PARAMETER Function
The name of the function to add a default parameter for. Wildcards are supported to match multiple functions.

.PARAMETER Parameter
The name of the parameter to set a default value for. Wildcards are supported to match multiple parameters.

.PARAMETER Value
The value to assign as the default for the specified parameter.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function Start-PSLauncher -Parameter PSLauncherConfigFile -Value C:\\temp\\PSLauncherConfig.json
Sets a default value for the 'PSLauncherConfigFile' parameter of the 'Start-PSLauncher' function.

.EXAMPLE
Add-PSDefaultParameterToPSConfigFile -Function *-Item -Parameter Path -Value C:\\Data -Force
Sets a default 'Path' for all functions ending with '-Item', overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to streamline your PowerShell workflow with persistent default parameters.
#>
function Add-PSDefaultParameterToPSConfigFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDefaultParameterToPSConfigFile')]
	[OutputType([System.Object[]])]
	param(
		[Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Name of a function to add, You can use wildcards to apply to more functions.')]
		[string]$Function,
		[Parameter(Position = 1, Mandatory = $true, HelpMessage = 'Name of a parameter to add, You can use wildcards to apply to more parameters.')]
		[string]$Parameter,
		[Parameter(Position = 2, Mandatory = $true, HelpMessage = 'The Value to add.')]
		[string]$Value,
		[switch]$Force
	)

	try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$XMLData = Import-Clixml -Path $confile.FullName
	$userdata = [PSCustomObject]@{
		Owner             = $XMLData.Userdata.Owner
		CreatedOn         = $XMLData.Userdata.CreatedOn
		PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
		Path              = $XMLData.Userdata.Path
		Hostname          = $XMLData.Userdata.Hostname
		PSEdition         = $XMLData.Userdata.PSEdition
		OS                = $XMLData.Userdata.OS
		BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = [datetime](Get-Date)
			ModifiedAction = "Add PSDefaultParameter $($Function):$($Parameter)"
		}
	}
	[System.Collections.generic.List[PSObject]]$PSDefaultObject = @()
	if ([string]::IsNullOrEmpty($XMLData.PSDefaults)) {
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	} else {
		$XMLData.PSDefaults | Where-Object {$_.Name -notlike "$($Function):$($Parameter)"} | ForEach-Object {[void]$PSDefaultObject.Add($_)}
		[void]$PSDefaultObject.Add([PSCustomObject]@{
				Name  = "$($Function):$($Parameter)"
				Value = $Value
			})
	}
	$Update = [psobject]@{
		Userdata    = $Userdata
		PSDrive     = $XMLData.PSDrive
		PSFunction  = $XMLData.PSFunction
		PSCreds     = $XMLData.PSCreds
		PSDefaults  = ($PSDefaultObject | Where-Object {$_ -notlike $null})
		SetLocation = $XMLData.SetLocation
		SetVariable = $XMLData.SetVariable
		Execute     = $XMLData.Execute
	}
	try {
		if ($force) {
			Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
			Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
		} else {
			Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
			Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
		}
		$Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
		Write-Host 'PSDefault Added: ' -ForegroundColor Green -NoNewline
		Write-Host "$($Function):$($Parameter)" -ForegroundColor Yellow
		Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
	} catch { Write-Error "Error: `n $_" }
} #end Function

 
Export-ModuleMember -Function Add-PSDefaultParameterToPSConfigFile
#endregion
 
#region Add-PSDriveToPSConfigFile.ps1
######## Function 6 of 15 ##################
# Function:         Add-PSDriveToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:55 AM
# ModifiedOn:       3/3/2026 1:18:39 PM
# Synopsis:         Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.
#############################################
 
<#
.SYNOPSIS
Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.

.DESCRIPTION
Use this function to register a PowerShell drive (PSDrive) in your configuration file. When the config is invoked, the drive will be automatically available in your session, streamlining access to file systems, registries, or other providers. The PSDrive must already exist (use New-PSDrive to create it first).

.PARAMETER DriveName
The name of the PSDrive to add. The drive must already exist in the current session.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
New-PSDrive -Name TempDir -PSProvider FileSystem -Root "C:\\Temp"
Add-PSDriveToPSConfigFile -DriveName TempDir
Registers the 'TempDir' PSDrive in the config file for automatic use in future sessions.

.EXAMPLE
Add-PSDriveToPSConfigFile -DriveName ProdModules -Force
Adds the 'ProdModules' PSDrive, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to ensure custom drives are always available in your PowerShell environment.
#>
function Add-PSDriveToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile')]
    param(
        [ValidateScript({ if (Get-PSDrive $_) { $true } else { $false } })]
        [string]$DriveName,
        [switch]$Force
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
   } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }

    $XMLData = Import-Clixml -Path $confile.FullName
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Added PSDrive: $($DriveName)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$PSDriveObject = @()
    $InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name, Root
    if ($null -eq $InputDrive) { Write-Error 'Unknown psdrive'; break }

    if ([string]::IsNullOrEmpty($XMLData.PSDrive)) {
        $PSDriveObject.Add([PSCustomObject]@{
                Name = $InputDrive.Name
                Root = $InputDrive.Root
            })
    } else {
        $XMLData.PSDrive | Where-Object {$_.Name -notlike $InputDrive.Name} | ForEach-Object {$PSDriveObject.Add($_)}
        $PSDriveObject.Add([PSCustomObject]@{
                Name = $InputDrive.Name
                Root = $InputDrive.Root
            })
    }

    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = ($PSDriveObject | Where-Object {$_ -notlike $null})
        PSFunction  = $XMLData.PSFunction
        PSCreds     = $XMLData.PSCreds
        PSDefaults  = $XMLData.PSDefaults
        SetLocation = $XMLData.SetLocation
        SetVariable = $XMLData.SetVariable
        Execute     = $XMLData.Execute
    }
    try {
        Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm).xml" -Force
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'PSDrive Added: ' -ForegroundColor Green -NoNewline
        Write-Host "$($DriveName)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function


 
Export-ModuleMember -Function Add-PSDriveToPSConfigFile
#endregion
 
#region Add-VariableToPSConfigFile.ps1
######## Function 7 of 15 ##################
# Function:         Add-VariableToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:53 AM
# ModifiedOn:       3/3/2026 12:59:07 PM
# Synopsis:         Adds one or more existing variables to the PSConfigFile configuration for automatic session import.
#############################################
 
<#
.SYNOPSIS
Adds one or more existing variables to the PSConfigFile configuration for automatic session import.

.DESCRIPTION
This function allows you to store the values of existing variables in your configuration file. When the config is invoked, these variables will be automatically recreated in your session, making it easy to persist tokens, paths, or other important values across PowerShell sessions. SecureString and PSCredential types are not allowed for security reasons.

.PARAMETER VariableNames
The name(s) of the variable(s) to add. Each variable must already exist in the current session.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Add-VariableToPSConfigFile -VariableNames AzureToken
Adds the 'AzureToken' variable to the config file for automatic import in future sessions.

.EXAMPLE
Add-VariableToPSConfigFile -VariableNames Path1,Path2 -Force
Adds both 'Path1' and 'Path2' variables, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to persist important variables between PowerShell sessions.
#>
function Add-VariableToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile')]
    param(
        [ValidateScript( { ( Get-Variable $_) })]
        [string[]]$VariableNames,
        [switch]$Force
    )
    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }

    $XMLData = Import-Clixml -Path $confile.FullName
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = "Added variable: $($VariableNames)"
        }
    }

    foreach ($VariableName in $VariableNames) {
        $Update = @()
        [System.Collections.generic.List[PSObject]]$VarObject = @()
        $InputVar = Get-Variable -Name $VariableName
        $inputtype = $InputVar.Value.GetType()
        if ($inputtype.Name -like 'PSCredential' -or $inputtype.Name -like 'SecureString') { Write-Error 'PSCredential or SecureString not allowed'; break }

        if ([string]::IsNullOrEmpty($XMLData.SetVariable)) {
            $VarObject.Add([PSCustomObject]@{
                    Name  = $InputVar.Name.ToString()
                    value = $InputVar.Value
                })        
        } else {
            $XMLData.SetVariable | Where-Object {$_.Name -notlike $InputVar.Name.ToString()} | ForEach-Object {$VarObject.Add($_)}
            $VarObject.Add([PSCustomObject]@{
                    Name  = $InputVar.Name.ToString()
                    value = $InputVar.Value
                })
        }

        $Update = [psobject]@{
            Userdata    = $Userdata
            PSDrive     = $XMLData.PSDrive
            PSFunction  = $XMLData.PSFunction
            PSCreds     = $XMLData.PSCreds
            PSDefaults  = $XMLData.PSDefaults
            SetLocation = $XMLData.SetLocation
            SetVariable = ($VarObject | Where-Object {$_ -notlike $null})
            Execute     = $XMLData.Execute
        }
        try {
            if ($force) {
                Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
                Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
            } else {
                Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
                Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
            }
            $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
            Write-Host 'Variable Added: ' -ForegroundColor Green -NoNewline
            Write-Host "$($VariableNames)" -ForegroundColor Yellow
            Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
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
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:04 AM
# ModifiedOn:       3/3/2026 10:00:48 AM
# Synopsis:         Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Exports the self-signed certificate (PFX) used for credential encryption in your PSConfigFile configuration.

.DESCRIPTION
Use this function to export the self-signed certificate (in PFX format) that is used to encrypt and decrypt credentials in your PSConfigFile configuration. Exporting the certificate allows you to import it on other machines, enabling secure decryption of credentials across trusted systems. You must provide a credential to protect the exported PFX file.

.PARAMETER Path
The directory path where the exported PFX file will be saved. The directory will be created if it does not exist.

.PARAMETER Credential
The credential (username and password) used to protect the exported PFX file. Use Get-Credential to create this object.

.EXAMPLE
$creds = Get-Credential
Export-PSConfigFilePFX -Path C:\temp -Credential $creds
Exports the certificate to C:\temp, protected by the provided credentials.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to securely transfer your credential encryption certificate to other systems.
#>
function Export-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Export-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	param(
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[Parameter(Mandatory)]
		[System.IO.DirectoryInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName PFXExport -Message 'For the exported pfx file')
	)

	$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
	if (-not($selfcert)) { Write-Warning 'Certificate does not exist, nothing to export'}
	else {
		if (Test-Path (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx')) {
			Rename-Item -Path (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx') -NewName "PSConfigFileCert-$(Get-Date -Format yyyy.MM.dd-HH.mm).pfx"
		}
		$selfcert | Export-PfxCertificate -NoProperties -NoClobber -Force -CryptoAlgorithmOption AES256_SHA256 -ChainOption EndEntityCertOnly -Password $Credential.Password -FilePath (Join-Path -Path $Path -ChildPath '\PSConfigFileCert.pfx')
	}

} #end Function
 
Export-ModuleMember -Function Export-PSConfigFilePFX
#endregion
 
#region Import-PSConfigFilePFX.ps1
######## Function 9 of 15 ##################
# Function:         Import-PSConfigFilePFX
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:58 AM
# ModifiedOn:       3/3/2026 10:00:48 AM
# Synopsis:         Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.

.DESCRIPTION
Use this function to import a self-signed certificate (in PFX format) that is used to decrypt credentials in your PSConfigFile configuration. This is useful when moving your configuration to a new system or restoring access to encrypted credentials. You must provide the credential used to protect the PFX file. Optionally, you can force the import to override existing certificates.

.PARAMETER Path
The path to the PFX file to import. Must be a valid .pfx file.

.PARAMETER Credential
The credential (username and password) that was used to protect the PFX file. Use Get-Credential to create this object.

.PARAMETER Force
If specified, will override any existing certificates with the same name.

.EXAMPLE
$creds = Get-Credential
Import-PSConfigFilePFX -Path C:\temp\PSConfigFileCert.pfx -Credential $creds
Imports the certificate from C:\temp, using the provided credentials for decryption.

.EXAMPLE
Import-PSConfigFilePFX -Path .\PSConfigFileCert.pfx -Credential (Get-Credential) -Force
Imports and overwrites any existing certificate with the same name.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to restore credential decryption capability on new or rebuilt systems.
#>
function Import-PSConfigFilePFX {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Import-PSConfigFilePFX')]
	[OutputType([System.Object[]])]
	param(
		[Parameter(Mandatory)]
		[ValidateScript( { if ((Get-Item $_).Extension -like '.pfx') { $true }
				else {throw 'Not a valid .pfx file'}	
			})]
		[System.IO.FileInfo]$Path,
		[pscredential]$Credential = (Get-Credential -UserName InportPFX -Message 'For the imported pfx file'),
		[switch]$Force = $false
	)
	$CheckExisting = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue 
	if (-not([string]::IsNullOrEmpty($CheckExisting))) {
		if ($Force) {$CheckExisting | ForEach-Object {Remove-Item Cert:\CurrentUser\My\$($_.Thumbprint) -Force}}
		else {
			Write-Warning 'Certificate already exists, use -Force to override the existing certificate'
			return
		}
	}
	Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $Path -Password $Credential.Password 
} #end Function
 
Export-ModuleMember -Function Import-PSConfigFilePFX
#endregion
 
#region Invoke-PSConfigFile.ps1
######## Function 10 of 15 ##################
# Function:         Invoke-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:00 AM
# ModifiedOn:       3/3/2026 12:46:08 PM
# Synopsis:         Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.
#############################################
 
<#
.SYNOPSIS
Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.

.DESCRIPTION
Use this function to load a PSConfigFile XML configuration file and apply all stored settings to your current session. This includes setting variables, creating PSDrives, defining functions, importing credentials, applying default parameters, setting the working directory, and executing startup commands. Use this to quickly restore your preferred environment or automate session setup across systems.

.PARAMETER ConfigFile
The path to the configuration XML file created by New-PSConfigFile. Must have a .xml extension.

.PARAMETER DisplayOutput
If specified, displays detailed output of each configuration step. Otherwise, only completion status is shown. Use Show-PSConfigFile to display the last execution output.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\config\PSConfigFile.xml
Loads and applies all settings from the specified config file.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile .\PSConfigFile.xml -DisplayOutput
Runs the config file and displays detailed output for each step.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to automate and standardize your PowerShell environment setup.
#>
function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.xml') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

    try {
        $confile = Get-Item $ConfigFile -ErrorAction stop
    } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }
    #region import file
    try {
        $confile = Get-Item $ConfigFile -ErrorAction Stop
        $XMLData = Import-Clixml -Path $confile.FullName
        if ([string]::IsNullOrEmpty($XMLData.Userdata)) { Write-Error 'Valid Parameters file not found'; break }
    } catch {Write-Warning "Error Import: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Import: Message:$($_.Exception.Message)") }

    try {
        $Script:PSConfigFileOutput = [System.Collections.Generic.List[string]]::new()
        $PSConfigFileOutput.Add('')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Module Version', "$((Get-Module PSConfigFile -ListAvailable | Sort-Object -Property Version -Descending)[0].Version)"
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Using PSCustomConfig File', "$($confile.fullname)"
        $PSConfigFileOutput.Add($output)
    } catch {Write-Warning "Error Config Start: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Config Start: Message:$($_.Exception.Message)") }
    #endregion

    #region User Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ################### Config File: Meta Data ###################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creation Data:")
        $XMLData.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
        $BackupsToDelete = Get-ChildItem "$($confile.Directory)\Outdated_PSConfigFile*" | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $($XMLData.Userdata.BackupsToKeep)
        if ($null -ne $BackupsToDelete) {
            $BackupsToDelete | Remove-Item -Force -ErrorAction Stop
            #$output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'Backups Removed', $($BackupsToDelete.count)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region User Data Modified
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Modification Data:")
        $XMLData.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
            $PSConfigFileOutput.Add($output)
        }
    } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
    #endregion

    #region Session Data
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ###################### Session Details: ######################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Current Session:")
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'User', "$($env:USERNAME.ToLower())" 
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'PSExecutionPolicy', $env:PSExecutionPolicyPreference
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'Hostname', (([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName).ToLower()
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'PSEdition', "$($PSVersionTable.PSEdition) (ver $($PSVersionTable.PSVersion.ToString()))"
        $PSConfigFileOutput.Add($output)
        $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f 'OS', (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $PSConfigFileOutput.Add($output)
    } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
    #endregion

    #region Set Variables
    try {
        $PSConfigFileOutput.Add('<h>  ')
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #################### Config File Details: ####################")
        $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Variables:")
        if (-not [string]::IsNullOrEmpty($XMLData.SetVariable)) {
            foreach ($SetVariable in  ($XMLData.SetVariable | Where-Object {$_ -notlike $null})) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetVariable.name), $($SetVariable.value)
                $PSConfigFileOutput.Add($output)
                try {
                    New-Variable -Name $($SetVariable.name) -Value $($SetVariable.value) -Force -Scope global -ErrorAction Stop
                } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
            }
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
    if (-not [string]::IsNullOrEmpty($XMLData.PSDrive)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
            foreach ($SetPSDrive in  ($XMLData.PSDrive | Where-Object {$_ -notlike $null})) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSDrive.Name), $($SetPSDrive.root)
                $PSConfigFileOutput.Add($output)
                if (-not(Get-PSDrive -Name $SetPSDrive.name -ErrorAction SilentlyContinue)) {
                    New-PSDrive -Name $SetPSDrive.name -PSProvider FileSystem -Root $SetPSDrive.root -Scope Global | Out-Null
                } else {$PSConfigFileOutput.Add('<w>Warning: PSDrive - Already exists') }
            }
        } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Set Function
    if (-not [string]::IsNullOrEmpty($XMLData.PSFunction)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Functions: ")
            foreach ($SetPSFunction in  ($XMLData.PSFunction | Where-Object {$_ -notlike $null})) {
                $tmp = $null
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSFunction.name), $($SetPSFunction.Command)
                $PSConfigFileOutput.Add($output)
                $command = "function global:$($SetPSFunction.name) {$($SetPSFunction.command)}"
                $tmp = [scriptblock]::Create($command)
                $tmp.invoke()
            }
        } catch {Write-Warning "Error Function: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Function: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Creds
    if (-not [string]::IsNullOrEmpty($XMLData.PSCreds)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
            if (($XMLData.PSCreds.edition -contains 'PSDesktop') -and $PSVersionTable.edition -eq 'PSDesktop') {
                Write-Error ' PSConfigFile Credentials is only a PSCore feature'; $PSConfigFileOutput.Add('<e>Error Credentials: Message: PSConfigFile Credentials is only a PSCore feature')
            }
            foreach ($Cred in ($XMLData.PSCreds | Where-Object {$_.Edition -like 'PSCore'})) {
                if ($null -ne $Cred) {
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
    }
    #endregion

    #region Set PSDefaults
    if (-not [string]::IsNullOrEmpty($XMLData.PSDefaults)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting PSDefaultParameterValues:")
            $SortDefaults = ($XMLData.PSDefaults | Where-Object {$_ -notlike $null}) | Sort-Object -Property Name
            foreach ($PSD in $SortDefaults) {
                if ($global:PSDefaultParameterValues["$($PSD.Name)"]) {$global:PSDefaultParameterValues["$($PSD.Name)"] = $PSD.Value}
                else {$global:PSDefaultParameterValues.Add("$($PSD.Name)", "$($PSD.Value)")}
            }
            foreach ($Defaults in ($global:PSDefaultParameterValues.GetEnumerator() | Sort-Object -Property Name)) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($Defaults.Name.Split(':')[0]), $($Defaults.Name.Split(':')[1]), $($Defaults.Value)
                $PSConfigFileOutput.Add($output)
            }
        } catch {Write-Warning "Error PSDefaults $($PSD.Name): `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error PSDefaults $($PSD.Name): Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Set Location
    if ($null -ne $XMLData.SetLocation) {
        try {
            $SetPath = $XMLData.SetLocation[0]
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($SetPath.value))
            $PSConfigFileOutput.Add($output)
            if ($SetPath.type -eq 'PSDrive') {
                Set-Location "$($SetPath.Name):"
            } else { 
                Set-Location $($SetPath.value)
            }
        } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
    }
    #endregion

    #region Execute Commands
    if (-not [string]::IsNullOrEmpty($XMLData.execute)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Commands: ")
            foreach ($execute in  ($XMLData.execute | Where-Object {$_ -notlike $null})) {
                $tmp = $null
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($execute.name), $($execute.ScriptBlock)
                $PSConfigFileOutput.Add($output)
                $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())]  ScriptBlock Output:")
                $tmp = [scriptblock]::Create($execute.ScriptBlock)
                Invoke-Command $tmp -OutVariable output
                $PSConfigFileOutput.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] $($output | Out-String)")
            }
        } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
    }
    #endregion


    $PSConfigFileOutput.Add('<h>  ')
    $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
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
 
#region New-PSConfigCertificate.ps1
######## Function 11 of 15 ##################
# Function:         New-PSConfigCertificate
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        3/3/2026 9:56:58 AM
# ModifiedOn:       3/3/2026 10:00:50 AM
# Synopsis:         Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Creates or renews a self-signed certificate for encrypting credentials in your PSConfigFile configuration.

.DESCRIPTION
This function generates a new self-signed certificate (or renews an existing one) used to encrypt and decrypt credentials stored in your configuration file. This ensures your sensitive data remains secure and portable across trusted systems. After creating the certificate, all saved credentials are re-encrypted for continued security.

.EXAMPLE
New-PSConfigCertificate
Creates or renews the self-signed certificate for credential encryption and re-encrypts all saved credentials.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Run this if your certificate is expiring or you need to reset credential encryption.
#>
function New-PSConfigCertificate {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigCertificate')]
	[OutputType([System.Object[]])]
	#region Parameter
	param(
	)
	#endregion

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

	Update-PSConfigFileCredentials -RenewSavedPasswords 'All'
} #end Function
 
Export-ModuleMember -Function New-PSConfigCertificate
#endregion
 
#region New-PSConfigFile.ps1
######## Function 12 of 15 ##################
# Function:         New-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:10 AM
# ModifiedOn:       3/3/2026 10:00:50 AM
# Synopsis:         Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.
#############################################
 
<#
.SYNOPSIS
Creates a new PSConfigFile XML configuration file to store your PowerShell environment settings.

.DESCRIPTION
This function initializes a new configuration file in the specified directory, capturing your environment's settings, drives, functions, credentials, variables, and more. If a config file already exists in the folder, it will be renamed as a backup before creating the new one. You can specify how many backup copies to keep when the config changes.

.PARAMETER ConfigDir
The directory where the new config file will be created. The directory will be created if it does not exist.

.PARAMETER BackupsToKeep
The number of backup copies to keep when the config file is changed. Older backups beyond this number will be deleted automatically.

.EXAMPLE
New-PSConfigFile -ConfigDir C:\\Temp\\config -BackupsToKeep 3
Creates a new config file in C:\Temp\config and keeps up to 3 backup copies.

.EXAMPLE
New-PSConfigFile -ConfigDir .
Creates a new config file in the current directory with the default number of backups.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to start managing your PowerShell environment with a portable, versioned config file.
#>
function New-PSConfigFile {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript({
                if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ConfigDir,
        [Parameter(HelpMessage = 'The amount of backup copies to keep of the config file.')]
        [int]$BackupsToKeep = 3
    )

    function DafaultSettings {
        try {
            $Userdata = New-Object PSObject -Property @{
                Owner             = "$($env:USERNAME.ToLower())"
                CreatedOn         = (Get-Date -Format u)
                PSExecutionPolicy = $env:PSExecutionPolicyPreference
                Path              = "$((Join-Path (Get-Item $ConfigDir).FullName -ChildPath \PSConfigFile.xml))"
                Hostname          = (([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName).ToLower()
                PSEdition         = "$($PSVersionTable.PSEdition) (ver $($PSVersionTable.PSVersion.ToString()))"
                OS                = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
                BackupsToKeep     = $BackupsToKeep
                ModifiedData      = [PSCustomObject]@{
                    ModifiedDate   = [datetime](Get-Date)
                    ModifiedAction = 'Created initial config file'
                }
            }
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
        
        $SetLocation = New-Object PSObject -Property @{}
        $SetVariable = New-Object PSObject -Property @{}
        $Execute = New-Object PSObject -Property @{}
        $PSDrive = New-Object PSObject -Property @{}
        $PSFunction = New-Object PSObject -Property @{}
        $PSCreds = New-Object PSObject -Property @{}
        $PSDefaults = New-Object PSObject -Property @{}   
        #main
        New-Object PSObject -Property @{
            Userdata    = $Userdata
            PSDrive     = $PSDrive
            PSFunction  = $PSFunction
            PSCreds     = $PSCreds
            PSDefaults  = $PSDefaults
            SetLocation = $SetLocation
            SetVariable = $SetVariable
            Execute     = $Execute
        }

    }

    $Fullpath = Get-Item $ConfigDir
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
        $check = Test-Path -Path (Join-Path $Fullpath -ChildPath \PSConfigFile.xml) -ErrorAction SilentlyContinue
        if (-not($check)) {
            Write-Output 'Config File does not exit, creating default settings.'

            $data = DafaultSettings
            $data | Export-Clixml -Depth 10 -Path (Join-Path $Fullpath -ChildPath \PSConfigFile.xml) -Force -NoClobber -Encoding utf8
            Write-Host '[Created] ' -ForegroundColor Yellow -NoNewline; Write-Host "$((Join-Path $Fullpath -ChildPath \PSConfigFile.xml))" -ForegroundColor DarkRed
        } else {
            Write-Warning "ConfigFile exists, renaming file now to:`n`nPSConfigFile_$(Get-Date -Format ddMMyyyy_HHmm).xml"
            Rename-Item (Join-Path $Fullpath -ChildPath \PSConfigFile.xml) -NewName "PSConfigFile_$(Get-Date -Format ddMMyyyy_HHmm).xml"

            $data = DafaultSettings
            $data | Export-Clixml -Depth 10 -Path (Join-Path $Fullpath -ChildPath \PSConfigFile.xml) -Force -NoClobber -Encoding utf8
            Write-Host '[Created] ' -ForegroundColor Yellow -NoNewline; Write-Host "$((Join-Path $Fullpath -ChildPath \PSConfigFile.xml))" -ForegroundColor DarkRed
        }
    }
    Invoke-PSConfigFile -ConfigFile (Join-Path $Fullpath -ChildPath \PSConfigFile.xml) -DisplayOutput
}

 
Export-ModuleMember -Function New-PSConfigFile
#endregion
 
#region Remove-ConfigFromPSConfigFile.ps1
######## Function 13 of 15 ##################
# Function:         Remove-ConfigFromPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:01 AM
# ModifiedOn:       3/3/2026 1:18:39 PM
# Synopsis:         Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.

.DESCRIPTION
Use this function to remove a specific configuration item from your config file, such as a PSDrive, function, variable, command, credential, default parameter, or location. This is useful for cleaning up or updating your configuration as your environment changes. You can optionally force the config file to be deleted before saving the new one.

.PARAMETER Variable
The name(s) of the variable(s) to remove from the config file.

.PARAMETER PSDrive
The name(s) of the PSDrive(s) to remove from the config file.

.PARAMETER Function
The name(s) of the function(s) to remove from the config file.

.PARAMETER Command
The name(s) of the command(s) to remove from the config file.

.PARAMETER Credential
The name(s) of the credential(s) to remove from the config file.

.PARAMETER PSDefaults
The name(s) of the default parameter(s) to remove from the config file.

.PARAMETER Location
If specified, removes the default location from the config file.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Remove-ConfigFromPSConfigFile -PSDrive ProdMods
Removes the 'ProdMods' PSDrive from the config file.

.EXAMPLE
Remove-ConfigFromPSConfigFile -Variable AzureToken -Force
Removes the 'AzureToken' variable, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
This function is part of the PSConfigFile module for managing PowerShell configuration automation. Use this to keep your configuration file clean and up to date.
#>
function Remove-ConfigFromPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
    param(
        [string[]]$Variable,
        [string[]]$PSDrive,
        [string[]]$Function,
        [string[]]$Command,
        [string[]]$Credential,
        [string[]]$PSDefaults,
        [string[]]$Location,
        [switch]$Force
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
   } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }
    [System.Collections.Generic.List[pscustomobject]]$XMLData = @()
    $XMLData.Add((Import-Clixml -Path $confile.FullName))
    $userdataModAction = 'Removed Config: '

    if ($PSBoundParameters.ContainsKey('Variable')) {
        $userdataModAction += "Variable: $(($XMLData.SetVariable | Where-Object {$_.name -like "$($Variable)"}).name)`n"
        $SetVariable = $XMLData.SetVariable | Where-Object {$_.Name -notlike "$Variable"}
    } else { $SetVariable = $XMLData.SetVariable }

    if ($PSBoundParameters.ContainsKey('PSDrive')) {
        $userdataModAction += "PSDrive: $(($XMLData.PSDrive | Where-Object {$_.name -like "$($PSDrive)"}).name)`n"
        $SetPSDrive = $XMLData.PSDrive | Where-Object {$_.Name -notlike "$PSDrive"}
    } else { $SetPSDrive = $XMLData.PSDrive }

    if ($PSBoundParameters.ContainsKey('Function')) {
        $userdataModAction += "Function: $(($XMLData.PSFunction | Where-Object {$_.name -like "$($Function)"}).name)`n"
        $SetPSFunction = $XMLData.PSFunction | Where-Object {$_.Name -notlike "$Function"}
    } else { $SetPSFunction = $XMLData.PSFunction }

    if ($PSBoundParameters.ContainsKey('Command')) { 
        $userdataModAction += "Command: $(($XMLData.Execute | Where-Object {$_.name -like "$($Command)"}).name)`n"
        $SetExecute = $XMLData.Execute | Where-Object {$_.Name -notlike "$Command"}
    } else { $SetExecute = $XMLData.Execute }

    if ($PSBoundParameters.ContainsKey('Credential')) {
        $userdataModAction += "Credential: $(($XMLData.PSCreds | Where-Object {$_.name -like "$($Credential)"}).name)`n"
        $SetCreds = $XMLData.PSCreds | Where-Object {$_.name -notlike "$Credential"}
    } else { $SetCreds = $XMLData.PSCreds }

    if ($PSBoundParameters.ContainsKey('PSDefaults')) {
        $userdataModAction += "PSDefaults: $(($XMLData.PSDefaults | Where-Object {$_.name -like "$($PSDefaults)"}).name)`n"
        $SetPSDefaults = $XMLData.PSDefaults | Where-Object {$_.name -notlike "$PSDefaults"}
    } else { $SetPSDefaults = $XMLData.PSDefaults }

    if ($PSBoundParameters.ContainsKey('Location')) {
        $userdataModAction += "Removed Location`n"
        $SetLocation = [PSCustomObject]@()
    } else { $SetLocation = $XMLData.SetLocation }
    
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
        BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date)
            ModifiedAction = ($userdataModAction | Out-String).Trim()
        }
    }
    $Update = @()
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = ($SetPSDrive | Where-Object {$_ -notlike $null})
        PSFunction  = ($SetPSFunction | Where-Object {$_ -notlike $null})
        PSCreds     = ($SetCreds | Where-Object {$_ -notlike $null})
        PSDefaults  = ($SetPSDefaults | Where-Object {$_ -notlike $null})
        SetLocation = ($SetLocation | Where-Object {$_ -notlike $null})
        SetVariable = ($SetVariable | Where-Object {$_ -notlike $null})
        Execute     = ($SetExecute | Where-Object {$_ -notlike $null})
    }
    try {
        if ($force) {
            Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
            Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
        } else {
            Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
            Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
        }
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Host 'Config Removed: ' -ForegroundColor Green -NoNewline
        Write-Host "$(($userdataModAction | Out-String).Trim().Replace('Removed Config: ',$null))" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }
} #end Function

$PSVariable = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.SetVariable | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Variable -ScriptBlock $PSVariable
$PSDrive = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.PSDrive | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName PSDrive -ScriptBlock $PSDrive
$PSFunction = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.PSFunction | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Function -ScriptBlock $PSFunction
$PSCommand = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.Execute | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Command -ScriptBlock $PSCommand
$PSCredential = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.PSCreds | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Credential -ScriptBlock $PSCredential
$PSDefaults = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.PSDefaults | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName PSDefaults -ScriptBlock $PSDefaults
$Location = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    $XMLData.SetLocation | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { $_.name }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Location -ScriptBlock $Location
 
Export-ModuleMember -Function Remove-ConfigFromPSConfigFile
#endregion
 
#region Set-PSConfigFileExecution.ps1
######## Function 14 of 15 ##################
# Function:         Set-PSConfigFileExecution
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:16 AM
# ModifiedOn:       3/3/2026 1:18:39 PM
# Synopsis:         Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.
#############################################
 
<#
.SYNOPSIS
Configures your PowerShell profile or a module to automatically execute your PSConfigFile configuration at startup.

.DESCRIPTION
This function adds or removes the command to invoke your PSConfigFile configuration from your PowerShell profile or a specified module. This ensures your environment is set up automatically every time you start a new session. You can also choose to include the DisplayOutput parameter for verbose startup information.

.PARAMETER PSProfile
Specifies whether to add or remove the config execution command from your PowerShell profile. Accepts values like 'AddScript' or 'RemoveScript'.

.PARAMETER DisplayOutput
If specified, adds the DisplayOutput parameter to the invoke command in your profile for detailed output at startup.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile AddScript -DisplayOutput
Adds the config execution command with detailed output to your PowerShell profile.

.EXAMPLE
Set-PSConfigFileExecution -PSProfile RemoveScript
Removes the config execution command from your PowerShell profile.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to automate your environment setup every time you launch PowerShell.
#>

function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'AddScript',
        [switch]$DisplayOutput
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
   } catch {
        if ($IsWindows) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        } else {
            Write-Error 'No valid Config file found.'
            return
        }
    }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        if ($DisplayOutput) {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`"  -DisplayOutput #PSConfigFile

"@
        } else {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile

"@
        }


        if ($PSProfile -like 'AddScript') {

            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8
                Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }
        if ($PSProfile -like 'RemoveScript') {
            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Write-Host '[Removed]' -NoNewline -ForegroundColor Yellow; Write-Host ' From Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }

    }
} #end Function

 
Export-ModuleMember -Function Set-PSConfigFileExecution
#endregion
 
#region Update-PSConfigFileCredentials.ps1
######## Function 15 of 15 ##################
# Function:         Update-PSConfigFileCredentials
# Module:           PSConfigFile
# ModuleVersion:    0.1.40
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        3/3/2026 9:15:04 AM
# ModifiedOn:       3/3/2026 1:03:37 PM
# Synopsis:         Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.

.DESCRIPTION
This function allows you to renew the self-signed certificate used for credential encryption, and to re-encrypt or update saved credentials for your PowerShell environment. This is useful when certificates expire, passwords change, or you need to ensure compatibility across PowerShell editions (Core/Desktop). You can renew all credentials or select specific ones by name.

.PARAMETER RenewSavedPasswords
Specifies which saved credentials to renew. Use 'All' to renew all credentials, or provide an array of credential names. Run in both PowerShell Core and Desktop to ensure compatibility.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Update-PSConfigFileCredentials -RenewSavedPasswords All
Prompts to renew all saved credentials in the config file.

.EXAMPLE
Update-PSConfigFileCredentials -RenewSavedPasswords AdminUser,LabTest
Renews only the 'AdminUser' and 'LabTest' credentials.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to keep your credential storage secure and up to date.
#>
function Update-PSConfigFileCredentials {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Update-PSConfigFileCredentials')]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
	param(
		[string[]]$RenewSavedPasswords = 'All',
		[switch]$Force
	)
	##TODO Add parameters prefetch for userids.
 try {
		$confile = Get-Item $PSConfigFile -ErrorAction stop
	} catch {
		Add-Type -AssemblyName System.Windows.Forms
		$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
		$null = $FileBrowser.ShowDialog()
		$confile = Get-Item $FileBrowser.FileName
	}

	$XMLData = Import-Clixml -Path $confile.FullName
	$userdata = [PSCustomObject]@{
		Owner             = $XMLData.Userdata.Owner
		CreatedOn         = $XMLData.Userdata.CreatedOn
		PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
		Path              = $XMLData.Userdata.Path
		Hostname          = $XMLData.Userdata.Hostname
		PSEdition         = $XMLData.Userdata.PSEdition
		OS                = $XMLData.Userdata.OS
		BackupsToKeep     = $XMLData.Userdata.BackupsToKeep
		ModifiedData      = [PSCustomObject]@{
			ModifiedDate   = [datetime](Get-Date)
			ModifiedAction = 'Modified Credentials'
		}
	}

	function RedoPass {
		param([string[]]$RenewSavedPasswords)

		$selfcert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like 'CN=PSConfigFileCert*'} -ErrorAction SilentlyContinue
		$Update = @()
		[System.Collections.generic.List[PSObject]]$CredsObject = @()
		[System.Collections.generic.List[PSObject]]$RenewCredsObject = @()
		$AllCreds = $XMLData.PSCreds | Sort-Object -Property Name -Unique 

		if ($RenewSavedPasswords -like 'All') {
			$AllCreds | ForEach-Object { $RenewCredsObject.Add($_) }
		} else {
			foreach ($credName in $RenewSavedPasswords) {
				$AllCreds | Where-Object { $_.Name -like $credName } | ForEach-Object { $RenewCredsObject.Add($_) }
			}
			$RenewCredsObject = $RenewCredsObject | Sort-Object -Property Name -Unique
		}

		foreach ($cred in $RenewCredsObject) {
			$tmpcred = Get-Credential -UserName $cred.UserName -Message 'Renew Password'
			$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpcred.Password)
			$PlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
			$EncodedPwd = [system.text.encoding]::UTF8.GetBytes($PlainText)
			if ($PSVersionTable.PSEdition -like 'Desktop') {
				Write-Error 'Credentials is only a feature of Powershell core.'
				return
			} else {
				$Edition = 'PSCore'
				$EncryptedBytes = $selfcert.PublicKey.Key.Encrypt($EncodedPwd, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512)
			}
			$EncryptedPwd = [System.Convert]::ToBase64String($EncryptedBytes)
			$CredsObject.Add([PSCustomObject]@{
					Name         = $cred.name
					Edition      = $Edition
					UserName     = $cred.UserName
					EncryptedPwd = $EncryptedPwd
				})
		}

		$Update = [psobject]@{
			Userdata    = $Userdata
			PSDrive     = $XMLData.PSDrive
			PSFunction  = $XMLData.PSFunction
			PSCreds     = ($CredsObject | Where-Object {$_ -notlike $null} | Sort-Object -Property Name)
			PSDefaults  = $XMLData.PSDefaults
			SetLocation = $XMLData.SetLocation
			SetVariable = $XMLData.SetVariable
			Execute     = $XMLData.Execute
		}
		try {
			if ($Force) {
				Remove-Item -Path $confile.FullName -Force -ErrorAction Stop
				Write-Host 'Original ConfigFile Removed' -ForegroundColor Red
			} else {
				Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm)_$(Get-Random -Maximum 50).xml" -Force
				Write-Host 'Original ConfigFile Renamed' -ForegroundColor Yellow
			}
			$Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
			Write-Host 'Credentials Updated' -ForegroundColor Green
			Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
		} catch { Write-Error "Error: `n $_" }
	}

	if (-not([string]::IsNullOrEmpty($RenewSavedPasswords))) {RedoPass -RenewSavedPasswords $RenewSavedPasswords}

} #end Function

$PSCredential = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$confile = Get-Item $PSConfigFile
	$XMLData = Import-Clixml -Path $confile.FullName
	$var = @('All')
	$var += $XMLData.PSCreds | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object { "$($_.name)" }
	$var
}
Register-ArgumentCompleter -CommandName Update-PSConfigFileCredentials -ParameterName RenewSavedPasswords -ScriptBlock $PSCredential
 
Export-ModuleMember -Function Update-PSConfigFileCredentials
#endregion
 
#endregion
 
