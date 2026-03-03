
<#PSScriptInfo

.VERSION 1.1.5

.GUID dd6d4e7a-509e-423e-a972-f0e1a1c34b94

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
Created [22/05/2022_07:47] Initial Script Creating

.PRIVATEDATA

#> 




<# 

.DESCRIPTION 
 Will display existing config with the option to remove it from the config file 

#> 

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
