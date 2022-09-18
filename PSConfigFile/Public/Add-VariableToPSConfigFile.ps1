
<#PSScriptInfo

.VERSION 1.1.4

.GUID da6df4de-5b05-4796-bf82-345686b30e78

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS PowerShell ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [04/10/2021_19:05] Initial Script Creating
Updated [05/10/2021_08:30] Spit into more functions
Updated [08/10/2021_20:51] Getting ready to upload
Updated [14/10/2021_19:32] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#>









<#

.DESCRIPTION
Add a variable to the config file

#>

<#
.SYNOPSIS
Adds variable to the config file.

.DESCRIPTION
Adds variable to the config file.

.PARAMETER VariableNames
The name of the variable. (Needs to exist already)

.PARAMETER Force
Will delete the config file before saving the new one. If false, then the config file will be renamed.


.EXAMPLE
Add-VariableToPSConfigFile -VariableNames AzureToken

#>
Function Add-VariableToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-VariableToPSConfigFile')]
    PARAM(
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
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = [datetime](Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add variable $($VariableNames)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
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
                    $InputVar.Name.ToString() = $InputVar.Value
                })        
        } else {
            $XMLData.SetVariable | ForEach-Object {$VarObject.Add($_)}
            $VarObject.Add([PSCustomObject]@{
                    $InputVar.Name.ToString() = $InputVar.Value
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
            Write-Host 'Variable Added' -ForegroundColor Green
            Write-Host "ConfigFile: $($confile.FullName)" -ForegroundColor Cyan
        } catch { Write-Error "Error: `n $_" }
    }
} #end Function


$scriptblock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-Variable | Where-Object {$_.Name -like "$wordToComplete*"} | ForEach-Object {"$($_.name)"}  
}
Register-ArgumentCompleter -CommandName Add-VariableToPSConfigFile -ParameterName VariableNames -ScriptBlock $scriptBlock
