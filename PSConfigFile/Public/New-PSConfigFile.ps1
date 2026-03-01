
<#PSScriptInfo

.VERSION 1.1.4

.GUID ec11b3b9-d13e-43c9-8a6d-d42a65016554

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/09/2021_02:52] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#>









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
