############################################
# source: Add-AliasToPSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Creates Shortcuts (Aliases) to commands or script blocks

.DESCRIPTION
Creates Shortcuts (Aliases) to commands or script blocks

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER AliasName
Name to use for the command

.PARAMETER CommandToRun
Command to run in a string format

.EXAMPLE
Add-AliasToPSConfigFile -ConfigFile $PSConfigFile -AliasName psml -CommandToRun "import-module .\*.psm1 -force -verbose"

#>
Function Add-AliasToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-AliasToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateNotNullOrEmpty()]
        [string]$AliasName,
        [ValidateNotNullOrEmpty()]
        [string]$CommandToRun
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json

    $Update = @()
    $SetAlias = @{}

    if ($Json.PSAlias.Default -eq 'Default') {
        $SetAlias = @{
            $AliasName = $CommandToRun
        }
    }
    else {
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
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $SetAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force

} #end Function
 
############################################
# source: Add-CommandToPSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER ScriptBlockName
Name for the script block

.PARAMETER ScriptBlock
The commands to be executed

.EXAMPLE
Add-CommandToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\"

#>
Function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    ## TODO Allow user to modify the order
    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $Execute = @{}
    if ($Json.Execute.Default -eq 'Default') {
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
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force




} #end Function
 
############################################
# source: Add-LocationToPSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Adds default location to the config file.

.DESCRIPTION
Adds default location to the config file.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER Path
Path to be set.

.EXAMPLE
Add-LocationToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -Path c:\temp

#>
Function Add-LocationToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-LocationToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateScript( { ( Test-Path $_) })]
        [System.IO.DirectoryInfo]$Path
    )
    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $SetLocation = @{}
    $SetLocation += @{
        WorkerDir = $((Get-Item $path).FullName)
    }
    $Update = [psobject]@{
        Userdata    = $Json.Userdata
        PSDrive     = $Json.PSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force

} #end Function
 
############################################
# source: Add-PSDriveToPSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Add PSDrive to the config file.

.DESCRIPTION
Add PSDrive to the config file.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER DriveName
Name of the PSDrive (PSDrive needs to be created first with New-PSDrive)

.EXAMPLE
Add-PSDriveToPSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json -DriveName TempDrive

#>
Function Add-PSDriveToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-PSDriveToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateScript( { ( Get-PSDrive $_) })]
        [string]$DriveName
    )
    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $Update = @()
    $SetPSDrive = @{}
    $InputDrive = Get-PSDrive -Name $DriveName | Select-Object Name,Root
    if ($null -eq $InputDrive) {Write-Error "Unknown psdrive";break}
    if ($Json.PSDrive.Default -eq 'Default') {
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
        Userdata    = $Json.Userdata
        PSDrive     = $SetPSDrive
        PSAlias     = $Json.PSAlias
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $Json.Execute
    }
    $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
} #end Function

 
############################################
# source: Add-VariableToPSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Adds variable to the config file.

.DESCRIPTION
Adds variable to the config file.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER VariableNames
The name of the variable. (Needs to exist already)

.EXAMPLE
Add-VariableToPSConfigFile -ConfigFile $PSConfigFile -VariableNames AzureToken

#>
Function Add-VariableToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile')]
    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [ValidateScript( { ( Get-Variable $_) })]
        [string[]]$VariableNames
    )
    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json

    foreach ($VariableName in $VariableNames) {
        $Update = @()
        $SetVariable = @{}
        $InputVar = Get-Variable -Name $VariableName
        $inputtype = $InputVar.Value.GetType()
        if ($inputtype.Name -like 'PSCredential' -or $inputtype.Name -like 'SecureString') { Write-Error 'PSCredential or SecureString not allowed'; break }

        if ($Json.SetVariable.Default -eq 'Default') {
            $SetVariable = @{
                $InputVar.Name = $InputVar.Value
            }
        }
        else {
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
            Userdata    = $Json.Userdata
            PSDrive     = $Json.PSDrive
            PSAlias     = $Json.PSAlias
            SetLocation = $Json.SetLocation
            SetVariable = $SetVariable
            Execute     = $Json.Execute
        }
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigFile -Verbose -Force
    }
} #end Function
 
############################################
# source: Invoke-PSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Executes the config from the json file.

.DESCRIPTION
Executes the config from the json file.

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER DisplayOutput
Do not show the output on the console.

.EXAMPLE
Invoke-PSConfigFile -ConfigFile C:\Temp\jdh\PSCustomConfig.json

#>
Function Invoke-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Invoke-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [switch]$DisplayOutput = $false
    )
    $output = New-Item (Join-Path $env:TEMP -ChildPath "$(Get-Random).txt")
    & {
    try {
            $confile = Get-Item $ConfigFile -ErrorAction SilentlyContinue
            $logfile = Join-Path $confile.DirectoryName -ChildPath PSCustomConfigLog.log
            if ((Test-Path $logfile) -eq $false) { New-Item -Path $logfile -ItemType File -Force | Out-Null }

            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start"
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################"
            Write-Output " "
            
            $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
            if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)"
            
            # User Data
            Write-Output "  "
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:"
            $JSONParameter.Userdata.PSObject.Properties | ForEach-Object { 
                  Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] `t`t$($_.name) : $($_.value)"  
            }

            # Set Location
            if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
                Write-Output "  "
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Setting Folder Location: $($JSONParameter.SetLocation.WorkerDir)"
                Set-Location $JSONParameter.SetLocation.WorkerDir -ErrorAction SilentlyContinue
            }

            #Set Variables
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:"
            $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
                Write-Output "  "
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                New-Variable -Name $_.name -Value $_.value -Force -Scope global
            }
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFilePath : ($confile.Directory).FullName"
            New-Variable -Name 'PSConfigFilePath' -Value ($confile.Directory).FullName -Scope global -Force
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile : $($confile.FullName)"
            New-Variable -Name 'PSConfigFile' -Value $confile.FullName -Scope global -Force

            # Set PsDrives
            Write-Output "  "
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:"
            $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object { Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value.root)"
                if (-not(Get-PSDrive -Name $_.name -ErrorAction SilentlyContinue)) {
                    New-PSDrive -Name $_.name -PSProvider FileSystem -Root $_.value.root -Scope Global | Out-Null
                }
                else { Write-Warning '`nWarning: PSDrive - Already exists'}
            }

            # Set Alias
           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: "
            $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $tmp = $null
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                $command = "function global:$($_.name) {$($_.value)}"
                $tmp = [scriptblock]::Create($command)
                $tmp.invoke() | Tee-Object -FilePath $logfile -Append
            }

            # Execute Commands
            Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: "
            $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $tmp = $null
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] $($_.name) : $($_.value)"
                Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] ScriptBlock Output:"
                $tmp = [scriptblock]::Create($_.value)
                $tmp.invoke() | Tee-Object -FilePath $logfile -Append
            }

           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################"
           Write-Output "[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End"
    }
    catch {
        Write-Error "An Error...:`n $_.Exception `n $_.Exception.message"
    }
    } *> $output.FullName

    $Feedback = Get-Content $output.FullName
    $warning = Select-String -Path $output.FullName -Pattern 'Warning'
    $configErrors = Select-String -Path $output.FullName -Pattern 'Error'

    if ($DisplayOutput){ $Feedback}
    else {Write-Output "Invoke-PSConfigFile Completed: $($warning.count) Warnings; $($configErrors.count) Errors"}

    

} #end Function
 
############################################
# source: New-PSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Creates a new config file

.DESCRIPTION
Creates a new config file. If a config file already exists in that folder, it will be renamed.
It will also create a log file in the same directory. Log file will be used on every execution.

.PARAMETER ConfigDir
Directory to create config file

.EXAMPLE
 New-PSConfigFile -ConfigDir C:\Temp\jdh

#>
Function New-PSConfigFile {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSConfigFile/New-PSConfigFile')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Attributes -eq 'Directory') })]
        [System.IO.DirectoryInfo]$ConfigDir
    )

    # TODO Add rotation of the logs
    function DafaultSettings {
        $Userdata = @()
        $SetLocation = @()
        $SetVariable = @()
        $Execute = @()
        $PSAlias = @()

        $OSDetails = Get-ComputerInfo
        $Userdata = New-Object PSObject -Property @{
            Computer                       = $env:COMPUTERNAME
            WindowsProductName             = $OSDetails.WindowsProductName
            WindowsEditionId               = $OSDetails.WindowsEditionId
            WindowsInstallationType        = $OSDetails.WindowsInstallationType
            WindowsInstallDateFromRegistry = $OSDetails.WindowsInstallDateFromRegistry
            OsArchitecture                 = $OSDetails.OsArchitecture
            OsProductType                  = $OSDetails.OsProductType
            OsStatus                       = $OSDetails.OsStatus
            DomainName                     = $env:USERDNSDOMAIN
            Userid                         = $env:USERNAME
            CreatedOn                      = (Get-Date -Format yyyy/MM/dd_HH:MM)
        }
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
        #main
        New-Object PSObject -Property @{
            Userdata    = $Userdata
            PSDrive     = $PSDrive
            PSAlias     = $PSAlias
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
            $data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Verbose -Force
        }
        else {

            Write-Warning 'File exists, renaming file now'
            Rename-Item (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -NewName "PSCustomConfig_$(Get-Date -Format ddMMyyyy_HHmm).json"

            $data = DafaultSettings
            $data | ConvertTo-Json -Depth 5 | Out-File (Join-Path $Fullpath -ChildPath \PSCustomConfig.json) -Verbose -Force


        }
    }
}
 
############################################
# source: Set-PSConfigFileExecution.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Adds functionality to add the execution to your profile or a PowerShell module

.DESCRIPTION
Adds functionality to add the execution to your profile or a PowerShell module

.PARAMETER ConfigFile
Path to the the config file ($PSConfigfile is a default variable created with the config file)

.PARAMETER PSProfile
Enable or disable loading of config when your ps profile is loaded.

.PARAMETER PSModule
Enable or disable loading of config when a specific module is loaded.

.PARAMETER PathToPSM1File
Path to the .psm1 file

.PARAMETER ExecuteNow
Execute the config file, to make sure everything runs as expected.

.EXAMPLE
Set-PSConfigFileExecution -ConfigFile C:\Temp\jdh\PSCustomConfig.json -PSProfile AddScript -PSModule AddScript -PathToPSM1File C:\Utils\LabScripts\LabScripts.psm1

#>
Function Set-PSConfigFileExecution {
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [parameter(Mandatory)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
        [System.IO.FileInfo]$ConfigFile,
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSModule = 'Ignore',
        [Parameter(ParameterSetName = 'Module')]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.psm1') })]
        [System.IO.FileInfo]$PathToPSM1File,
        [switch]$ExecuteNow = $false
    )

    try {
        $confile = Get-Item $ConfigFile
        Test-Path -Path $confile.FullName
    }
    catch { throw 'Incorect file' }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        $string = @"

#PSConfigFile
`$PSConfigFileModule = get-item `"$((Join-Path $module.ModuleBase \PSConfigFile.psm1 -Resolve))`" #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile
"@

        if ($PSModule -like 'AddScript') {

            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*#PSConfigFile*' }
            Set-Content -Value ($ori + $string) -Path $PathToPSM1File -Verbose

        }
        if ($PSModule -like 'RemoveScript') {
            $ori = Get-Content $PathToPSM1File | Where-Object { $_ -notlike '*#PSConfigFile*' }
            Set-Content -Value ($ori) -Path $PathToPSM1File -Verbose
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
                Set-Content -Value ($ori + $string) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori + $string) -Path $vs -Verbose
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
                Set-Content -Value ($ori) -Path $ps -Verbose
            }
            if (Test-Path $ise) {
                $ori = Get-Content $ise | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $ise -Verbose
            }
            if (Test-Path $vs) {
                $ori = Get-Content $vs | Where-Object { $_ -notlike '*#PSConfigFile*' }
                Set-Content -Value ($ori) -Path $vs -Verbose
            }


        }
        if ($ExecuteNow) {
            Clear-Host
            Invoke-PSConfigFile -ConfigFile $($confile.FullName)
        }

    }


} #end Function

 
############################################
# source: Show-PSConfigFile.ps1
# Module: PSConfigFile
# version: 0.1.26
# Author: Pierre Smit
# Company: iOCO Tech
#############################################
 
<#
.SYNOPSIS
Display what's configured in the config file.

.DESCRIPTION
Display what's configured in the config file. But doesn't execute the commands

.EXAMPLE
Show-PSConfigFile

#>
Function Show-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Show-PSConfigFile')]
    param ()

    try {
        try{
            $confile = Get-Item $PSConfigFile -ErrorAction stop
        }catch {
            Add-Type -AssemblyName System.Windows.Forms

            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json'}
            $null = $FileBrowser.ShowDialog()
            $confile = Get-Item $FileBrowser.FileName
        }

        Write-Color 'PSConfigFile' -ShowTime -Color DarkCyan -LinesBefore 4
        Write-Color '#######################################################' -ShowTime -Color Green

        $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
        if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }
        Write-Color 'Using PSCustomConfig file: ', $($confile.fullname) -ShowTime -Color DarkCyan, DarkYellow

        # User Data
        Write-Color 'Details of Config File:' -ShowTime -Color DarkCyan -LinesBefore 1
        $JSONParameter.Userdata.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime -StartTab 4 }

        # Set Location
        if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
            Write-Color 'Setting Folder Location: ', $($JSONParameter.SetLocation.WorkerDir) -ShowTime -Color DarkCyan, DarkYellow -LinesBefore 1
        }

        #Set Variables
        Write-Color 'Setting Default Variables:' -ShowTime -Color DarkCyan -LinesBefore 1
        $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }
        Write-Color 'PSConfigFilePath', ':', ($confile.Directory).FullName -Color Yellow, DarkCyan, Green -ShowTime
        Write-Color 'PSConfigFile', ':', $confile.FullName -Color Yellow, DarkCyan, Green -ShowTime

        # Set PsDrives
        Write-Color 'Creating PSDrives:' -ShowTime -Color DarkCyan -LinesBefore 1
        $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object { Write-Color $_.name, ':', $_.value.root -Color Yellow, DarkCyan, Green -ShowTime }

        # Set Alias
        Write-Color 'Creating Custom Aliases: ' -ShowTime -Color DarkCyan -LinesBefore 1
        $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

        # Execute Commands
        Write-Color 'Executing Custom Commands: ' -ShowTime -Color DarkCyan -LinesBefore 1
        $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime }

        Write-Color '#######################################################' -ShowTime -Color Green -LinesBefore 1
        Write-Color 'PSConfigFile Execution End' -ShowTime -Color DarkCyan
    }
    catch {
        Write-Warning $_.Exception
        Write-Warning $_.Exception.message
    }
} #end Function
 
