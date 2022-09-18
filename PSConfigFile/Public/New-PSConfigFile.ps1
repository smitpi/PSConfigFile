
<#PSScriptInfo

.VERSION 1.1.4

.GUID ec11b3b9-d13e-43c9-8a6d-d42a65016554

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

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

.DESCRIPTION
To store your settings

#>


<#
.SYNOPSIS
Creates a new config file

.DESCRIPTION
Creates a new config file. If a config file already exists in that folder, it will be renamed.

.PARAMETER ConfigDir
Directory to create config file

.PARAMETER BackupsToKeep
The amount of copies to keep of the config file when config is changed.

.EXAMPLE
 New-PSConfigFile -ConfigDir C:\Temp\config -BackupsToKeep 3

#>
Function New-PSConfigFile {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_) {$true}
                else {New-Item -Path $_ -ItemType Directory -Force | Out-Null }
            })]
        [System.IO.DirectoryInfo]$ConfigDir,
        [Parameter(HelpMessage = 'The amount of backup copies to keep of the config file.')]
        [int]$BackupsToKeep = 10 
    )

    function DafaultSettings {
        try {
            $Userdata = New-Object PSObject -Property @{
                Owner             = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
                CreatedOn         = [datetime](Get-Date -Format u)
                PSExecutionPolicy = $env:PSExecutionPolicyPreference
                Path              = "$((Join-Path (Get-Item $ConfigDir).FullName -ChildPath \PSConfigFile.xml))"
                Hostname          = (([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName).ToLower()
                PSEdition         = "$($PSVersionTable.PSEdition) (ver $($PSVersionTable.PSVersion.ToString()))"
                OS                = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
                BackupsToKeep     = $BackupsToKeep
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
