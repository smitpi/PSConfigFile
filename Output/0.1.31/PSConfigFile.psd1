#
# Module manifest for module 'PSGet_PSConfigFile'
#
# Generated by: Pierre Smit
#
# Generated on: 2022-07-29 15:10:12Z
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSConfigFile.psm1'

# Version number of this module.
ModuleVersion = '0.1.31'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'd1fff6c2-e0c4-49ba-8632-e0137d78151c'

# Author of this module
Author = 'Pierre Smit'

# Company or vendor of this module
CompanyName = 'HTPCZA Tech'

# Copyright statement for this module
Copyright = '(c) 2021 Pierre Smit. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Creates a Config file with Commands, Variables, PSDrives, Credentials, Aliases\Shortcuts and a Default Starting location. You can then execute this config file when your profile is loaded, or when a specific module is imported, or you can run it manually. This way you can quickly and easily switch between "environment setups" with these default values'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('PSWriteColor')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-AliasToPSConfigFile', 'Add-CommandToPSConfigFile', 
               'Add-CredentialToPSConfigFile', 'Add-LocationToPSConfigFile', 
               'Add-PSDriveToPSConfigFile', 'Add-VariableToPSConfigFile', 
               'Invoke-PSConfigFile', 'New-PSConfigFile', 
               'Remove-ConfigFromPSConfigFile', 'Set-CredentialsInPSConfigFile', 
               'Set-PSConfigFileExecution', 'Show-PSConfigFile'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'config','defaults'

        # A URL to the license for this module.
        LicenseUri = 'https://raw.githubusercontent.com/smitpi/PSConfigFile/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/smitpi/PSConfigFile'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Updated [21/07/2022_05:58] Added Modified data to the report'

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://smitpi.github.io/PSConfigFile'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
