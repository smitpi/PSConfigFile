#region Public Functions
#region Add-CommandToPSConfigFile.ps1
######## Function 1 of 16 ##################
# Function:         Add-CommandToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:27 AM
# ModifiedOn:       3/1/2026 6:37:36 PM
# Synopsis:         Adds a command or script block to the config file, to be executed every time the invoke function is called.
#############################################
 
 
Export-ModuleMember -Function Add-CommandToPSConfigFile
#endregion
 
#region Add-CredentialToPSConfigFile.ps1
######## Function 2 of 16 ##################
# Function:         Add-CredentialToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:23 AM
# ModifiedOn:       3/1/2026 6:37:37 PM
# Synopsis:         Creates a self signed cert, then uses it to securely save a credential to the config file.
#############################################
 
 
Export-ModuleMember -Function Add-CredentialToPSConfigFile
#endregion
 
#region Add-FunctionToPSConfigFile.ps1
######## Function 3 of 16 ##################
# Function:         Add-FunctionToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:06 AM
# ModifiedOn:       3/1/2026 6:36:37 PM
# Synopsis:         Adds a custom function (shortcut) to the PSConfigFile configuration for quick command or script execution.
#############################################
 
<#
.SYNOPSIS
Adds a custom function (shortcut) to the PSConfigFile configuration for quick command or script execution.

.DESCRIPTION
This function allows you to define named PowerShell functions (shortcuts) that execute specific commands or script blocks. These functions are stored in your configuration file and can be invoked automatically or manually, streamlining repetitive tasks and environment setup.

.PARAMETER FunctionName
The name to assign to the custom function. This is how you will reference and call the function from your config.

.PARAMETER CommandToRun
The PowerShell command or script block (as a string) that the function will execute. Example: "Import-Module .\*.psm1 -Force -Verbose"

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
Use this to automate and simplify common PowerShell tasks.
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
        $XMLData.PSFunction | ForEach-Object {$FunctionObject.Add($_)}
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
######## Function 4 of 16 ##################
# Function:         Add-LocationToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:09 AM
# ModifiedOn:       3/1/2026 2:46:45 PM
# Synopsis:         Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Adds a default start-up location (folder or PSDrive) to the PSConfigFile configuration.

.DESCRIPTION
This function allows you to specify a default working location for your PowerShell session, either as a folder path or a PSDrive. When the config file is invoked, your session will automatically change to this location, streamlining your workflow and ensuring you always start in the right place.

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
Add-LocationToPSConfigFile -LocationType Folder -Path c:\\temp
Sets the default location to the 'c:\\temp' folder when the config is invoked.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to ensure your PowerShell session always starts in the correct directory or drive.
#>

function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    param(
        [Parameter(Mandatory = $true)]
        [validateSet('PSDrive', 'Folder')]
        [string]$LocationType,
        [Parameter(Mandatory = $true)]
        [ValidateScript( { ( Test-Path $_) -or ( [bool](Get-PSDrive $_)) })]
        [string]$Path,
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
    try {
        if ($LocationType -like 'PSDrive') {
            try {
                $Drive = Get-PSDrive $Path -ErrorAction Stop
                $PathName = $Drive.Name
                $PathValue = $Drive.Root
                $PathType = 'PSDrive'
            } catch {
                Write-Error 'PSDrive not found'
                exit
            }
        }
        if ($LocationType -like 'Folder') {
            [System.IO.DirectoryInfo]$Dir = $Path
            $AddPath = Get-Item $Dir
            $PathName = $AddPath.Directory
            $PathValue = $AddPath.FullName
            $PathType = 'Folder'

        }
    } catch { throw 'Could not find path' }

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
            ModifiedAction = "Working Directory Changed: $($Path)"
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$SetLocation = @()
    $SetLocation.Add([PSCustomObject]@{
            Name  = $PathName
            value = $PathValue
            Type  = $PathType
        })
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
        Write-Host "$($Path)" -ForegroundColor Yellow
        Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
    } catch { Write-Error "Error: `n $_" }

} #end Function
 
Export-ModuleMember -Function Add-LocationToPSConfigFile
#endregion
 
#region Add-PSDefaultParameterToPSConfigFile.ps1
######## Function 5 of 16 ##################
# Function:         Add-PSDefaultParameterToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:24 AM
# ModifiedOn:       3/1/2026 6:37:38 PM
# Synopsis:         Add PSDefaultParameterValues to the config file
#############################################
 
 
Export-ModuleMember -Function Add-PSDefaultParameterToPSConfigFile
#endregion
 
#region Add-PSDriveToPSConfigFile.ps1
######## Function 6 of 16 ##################
# Function:         Add-PSDriveToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:55 AM
# ModifiedOn:       3/1/2026 6:36:41 PM
# Synopsis:         Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.
#############################################
 
<#
.SYNOPSIS
Adds an existing PSDrive to the PSConfigFile configuration for automatic session setup.

.DESCRIPTION
This function allows you to register a PowerShell drive (PSDrive) in your configuration file. When the config is invoked, the drive will be automatically available in your session, streamlining access to file systems, registries, or other providers. The PSDrive must already exist (use New-PSDrive to create it first).

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
Use this to ensure custom drives are always available in your PowerShell environment.
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
        $XMLData.PSDrive | ForEach-Object {$PSDriveObject.Add($_)}
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
######## Function 7 of 16 ##################
# Function:         Add-VariableToPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:53 AM
# ModifiedOn:       3/1/2026 6:39:33 PM
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
            $XMLData.SetVariable | ForEach-Object {$VarObject.Add($_)}
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
######## Function 8 of 16 ##################
# Function:         Export-PSConfigFilePFX
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:04 AM
# ModifiedOn:       3/1/2026 6:37:40 PM
# Synopsis:         Export the PFX file for credentials.
#############################################
 
 
Export-ModuleMember -Function Export-PSConfigFilePFX
#endregion
 
#region Import-PSConfigFilePFX.ps1
######## Function 9 of 16 ##################
# Function:         Import-PSConfigFilePFX
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:45:58 AM
# ModifiedOn:       3/1/2026 8:36:43 AM
# Synopsis:         
Import-PSConfigFilePFX [-Path] <FileInfo> [[-Credential] <pscredential>] [-Force] [<CommonParameters>]

#############################################
 
<#
.SYNOPSIS
Imports a self-signed certificate (PFX) for credential decryption in your PSConfigFile configuration.

.DESCRIPTION
This function imports a self-signed certificate (in PFX format) that is used to decrypt credentials in your PSConfigFile configuration. This is useful when moving your configuration to a new system or restoring access to encrypted credentials. You must provide the credential used to protect the PFX file. Optionally, you can force the import to override existing certificates.

.PARAMETER Path
The path to the PFX file to import.

.PARAMETER Credential
The credential (username and password) that was used to protect the PFX file. Use Get-Credential to create this object.

.PARAMETER Force
If specified, will override any existing certificates with the same name.

.EXAMPLE
$creds = Get-Credential
Import-PSConfigFilePFX -Path C:\\temp\\PSConfigFileCert.pfx -Credential $creds
Imports the certificate from C:\temp, using the provided credentials for decryption.

.EXAMPLE
Import-PSConfigFilePFX -Path .\\PSConfigFileCert.pfx -Credential (Get-Credential) -Force
Imports and overwrites any existing certificate with the same name.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to restore credential decryption capability on new or rebuilt systems.
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
######## Function 10 of 16 ##################
# Function:         Invoke-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:00 AM
# ModifiedOn:       3/1/2026 3:10:55 PM
# Synopsis:         Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.
#############################################
 
<#
.SYNOPSIS
Reads and executes all configuration items from a PSConfigFile XML file, setting up your PowerShell session automatically.

.DESCRIPTION
This function loads a PSConfigFile XML configuration file and applies all stored settings to your current session. This includes setting variables, creating PSDrives, defining functions, importing credentials, applying default parameters, setting the working directory, and executing startup commands. Use this to quickly restore your preferred environment or automate session setup across systems.

.PARAMETER ConfigFile
The path to the configuration XML file created by New-PSConfigFile. Must have a .xml extension.

.PARAMETER DisplayOutput
If specified, displays detailed output of each configuration step. Otherwise, only completion status is shown. Use Show-PSConfigFile to display the last execution output.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\\Temp\\config\\PSConfigFile.xml
Loads and applies all settings from the specified config file.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile .\\PSConfigFile.xml -DisplayOutput
Runs the config file and displays detailed output for each step.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to automate and standardize your PowerShell environment setup.
#>
function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.xml') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )

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
    if (-not [string]::IsNullOrEmpty($XMLData.SetVariable)) {
        try {
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #################### Config File Details: ####################")
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Variables:")
            foreach ($SetVariable in  ($XMLData.SetVariable | Where-Object {$_ -notlike $null})) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetVariable.name), $($SetVariable.value)
                $PSConfigFileOutput.Add($output)
                try {
                    New-Variable -Name $($SetVariable.name) -Value $($SetVariable.value) -Force -Scope global -ErrorAction Stop
                } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
            }
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force -ErrorAction Stop
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $PSConfigFileOutput.Add($output)
            New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force -ErrorAction Stop
        } catch {Write-Warning "Error Variable: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Variable: Message:$($_.Exception.Message)")}
    }
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
    if (-not [string]::IsNullOrEmpty($XMLData.SetLocation)) {
        try {
            $SetPath = $XMLData.SetLocation[0]
            $PSConfigFileOutput.Add('<h>  ')
            $PSConfigFileOutput.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($SetPath.value))
            $PSConfigFileOutput.Add($output)
            if ($SetPath.type -eq 'PSDrive') {
                Set-Location "$($SetPath.Name):"
                else { Set-Location $($SetPath.value)}
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
######## Function 11 of 16 ##################
# Function:         New-PSConfigCertificate
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        3/1/2026 7:22:51 AM
# ModifiedOn:       3/1/2026 9:29:33 AM
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
######## Function 12 of 16 ##################
# Function:         New-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:10 AM
# ModifiedOn:       3/1/2026 8:29:45 AM
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
######## Function 13 of 16 ##################
# Function:         Remove-ConfigFromPSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:01 AM
# ModifiedOn:       3/1/2026 3:19:28 PM
# Synopsis:         Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.
#############################################
 
<#
.SYNOPSIS
Removes a specific item (variable, drive, function, command, credential, default, or location) from the PSConfigFile configuration.

.DESCRIPTION
This function allows you to remove a specific configuration item from your config file, such as a PSDrive, function, variable, command, credential, default parameter, or location. This is useful for cleaning up or updating your configuration as your environment changes. You can optionally force the config file to be deleted before saving the new one.

.PARAMETER Config
The type of configuration item to remove. Valid values: Variable, PSDrive, Function, Command, Credential, PSDefaults, Location.

.PARAMETER Value
The value or name of the item to remove. For example, the name of the drive, function, or variable.

.PARAMETER Force
If specified, the config file will be deleted before saving the new one. If not specified and a config file exists, it will be renamed as a backup before saving the new version.

.EXAMPLE
Remove-ConfigFromPSConfigFile -Config PSDrive -Value ProdMods
Removes the 'ProdMods' PSDrive from the config file.

.EXAMPLE
Remove-ConfigFromPSConfigFile -Config Variable -Value AzureToken -Force
Removes the 'AzureToken' variable, overwriting the config file if it exists.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to keep your configuration file clean and up to date.
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
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
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

$SetVariable = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    if ($null -notlike $XMLData.SetVariable) {
        $XMLData.SetVariable.Name
    }
}
$PSDrive = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    if ($null -notlike $XMLData.PSDrive) {
        $XMLData.PSDrive.Name
    }
}
$Execute = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    if ($null -notlike $XMLData.Command) {
        $XMLData.Execute.Name
    }
}
$PSCreds = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    if ($null -notlike $XMLData.PSCreds) {
        $XMLData.PSCreds.Name
    }
}
$PSDefaults = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $confile = Get-Item $PSConfigFile
    $XMLData = Import-Clixml -Path $confile.FullName
    if ($null -notlike $XMLData.PSDefaults) {
        $XMLData.PSDefaults.Name
    }
}
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Variable -ScriptBlock $SetVariable
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName PSDrive -ScriptBlock $PSDrive
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Command -ScriptBlock $Execute
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName Credential -ScriptBlock $PSCreds
Register-ArgumentCompleter -CommandName Remove-ConfigFromPSConfigFile -ParameterName PSDefaults -ScriptBlock $PSDefaults
 
Export-ModuleMember -Function Remove-ConfigFromPSConfigFile
#endregion
 
#region Set-PSConfigFileExecution.ps1
######## Function 14 of 16 ##################
# Function:         Set-PSConfigFileExecution
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:16 AM
# ModifiedOn:       3/1/2026 8:37:40 AM
# Synopsis:         
Set-PSConfigFileExecution [-PSProfile <string>] [-DisplayOutput] [-WhatIf] [-Confirm] [<CommonParameters>]

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
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
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
 
#region Show-PSConfigFile.ps1
######## Function 15 of 16 ##################
# Function:         Show-PSConfigFile
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:13 AM
# ModifiedOn:       3/1/2026 8:33:45 AM
# Synopsis:         
Show-PSConfigFile [[-OtherConfigFile] <FileInfo>] [-ShowLastInvokeOutput] [<CommonParameters>]

#############################################
 
<#
.SYNOPSIS
Displays the contents and configuration details of a PSConfigFile XML file without executing any commands.

.DESCRIPTION
This function provides a detailed, human-readable summary of what is configured in your PSConfigFile XML file. It shows all stored variables, drives, functions, credentials, default parameters, and startup locations, as well as metadata and modification history. You can also display the output of the last Invoke-PSConfigFile execution for troubleshooting or auditing purposes.

.PARAMETER ShowLastInvokeOutput
If specified, displays the output of the last Invoke-PSConfigFile execution instead of the config file details.

.PARAMETER OtherConfigFile
The path to a different config file to display, instead of the default one.

.EXAMPLE
Show-PSConfigFile -ShowLastInvokeOutput
Displays the output of the last config file execution.

.EXAMPLE
Show-PSConfigFile -OtherConfigFile C:\\Temp\\config\\PSConfigFile.xml
Displays the configuration details of the specified config file.

.NOTES
Author: Pierre Smit
Website: https://smitpi.github.io/PSConfigFile
Use this to review, audit, or troubleshoot your PowerShell configuration without making changes to your session.
#>

#>
function Show-PSConfigFile {
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
                $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
                $null = $FileBrowser.ShowDialog()
                $confile = Get-Item $FileBrowser.FileName
            } else {
                try {
                    $confile = Get-Item $OtherConfigFile -ErrorAction stop
                } catch {
                    Add-Type -AssemblyName System.Windows.Forms
                    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
                    $null = $FileBrowser.ShowDialog()
                    $confile = Get-Item $FileBrowser.FileName
                }
            }
            #region Import xml
            $XMLData = Import-Clixml -Path $confile.FullName
            if ([string]::IsNullOrEmpty($XMLData)) { Write-Error 'Valid Parameters file not found'; break }
            $outputfile = [System.Collections.Generic.List[string]]::new()
            $outputfile.Add('')

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Details")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Module Version', "$((Get-Module PSConfigFile -ListAvailable | Sort-Object -Property Version -Descending)[0].Version)"
            $outputfile.Add($output)
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Showing PSCustomConfig file', "$($confile.fullname)"
            $outputfile.Add($output)
            #endregion

            #region User Data
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ################### Config File: Meta Data ###################")
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creation Data:")
                $XMLData.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
            #endregion

            #region User Data Modified
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())]  Modification Data:")
                $XMLData.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
            #endregion

            #region Set Variables
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #################### Config File Details: ####################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Variables to be created:")
            foreach ($SetVariable in  ($XMLData.SetVariable | Where-Object {$_ -notlike $null})) {
                $VarMember = $SetVariable | Get-Member -MemberType NoteProperty, Property
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($VarMember.name), $($SetVariable.$($VarMember.name))
                $outputfile.Add($output)
            }
            $PSConfigFilePathoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $outputfile.Add($PSConfigFilePathoutput)
            $PSConfigFileoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $outputfile.Add($PSConfigFileoutput)
            #endregion

            #region Set PsDrives
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSDrives to be created:")
                foreach ($SetPSDrive in  ($XMLData.PSDrive | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSDrive.Name), $($SetPSDrive.root)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
            #endregion

            #region Set Function
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Functions to be created: ")
                foreach ($SetPSFunction in  ($XMLData.PSFunction | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSFunction.name), $($SetPSFunction.Command)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Function: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error Function: Message:$($_.Exception.Message)")}
            #endregion

            #region Creds
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Credentials to be created: ")
            foreach ($Cred in ($XMLData.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"})) {
                $credname = $Cred.Name
                $username = $Cred.UserName
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($credname), "(PS$($PSVersionTable.PSEdition)) $($username)"
                $outputfile.Add($output)
            }
            #endregion

            #region Set PSDefaults
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSDefaultParameterValues to be created:")
            foreach ($PSD in  $XMLData.PSDefaults) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($PSD.Name.Split(':')[0]), $($PSD.Name.Split(':')[1]), $($PSD.Value)
                $outputfile.Add($output)
            }
            #endregion

            #region Set Location
            try {
                if (-not([string]::IsNullOrEmpty($XMLData.SetLocation))) {
                    $outputfile.Add('<h>  ')
                    $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Working Directory to be set: ")
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($XMLData.SetLocation.WorkerDir))
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
            #endregion

            #region Execute Commands
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Commands to be executed: ")
                foreach ($execute in  ($XMLData.execute | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($execute.name), $($execute.ScriptBlock)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
            #endregion

            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Details End")
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
 
#region Update-PSConfigFileCredentials.ps1
######## Function 16 of 16 ##################
# Function:         Update-PSConfigFileCredentials
# Module:           PSConfigFile
# ModuleVersion:    0.1.41
# Author:           Pierre Smit
# Company:          Private
# CreatedOn:        11/26/2024 11:46:19 AM
# ModifiedOn:       3/1/2026 8:29:46 AM
# Synopsis:         Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration.
#############################################
 
<# 

.DESCRIPTION 
 Updates or renews credentials and encryption certificates stored in your PSConfigFile configuration. 

#> 

Param()


 
Export-ModuleMember -Function Update-PSConfigFileCredentials
#endregion
 
#endregion
 
