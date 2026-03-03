
<#PSScriptInfo

.VERSION 1.1.5

.GUID a811aeae-b035-4631-aca6-6be058179ecc

.AUTHOR Pierre Smit

.COMPANYNAME Private

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
 Adds variable to the config file. 

#> 


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
            exit
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

