
<#PSScriptInfo

.VERSION 0.1.0

.GUID dd6d4e7a-509e-423e-a972-f0e1a1c34b94

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
Created [22/05/2022_07:47] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Will display existing config with the option to remove it from the config file 

#> 


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

.PARAMETER Credential
Name of the Credential to remove.

.PARAMETER Location
Set Location to blank again.

.EXAMPLE
Remove-ConfigFromPSConfigFile -PSDrive ProdMods

#>
Function Remove-ConfigFromPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
    PARAM(
        [string[]]$Variable,
        [string[]]$PSDrive,
        [string[]]$PSAlias,
        [string[]]$Command,
        [SecureString[]]$Credential,
        [switch]$Location
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

    if (-not([string]::IsNullOrEmpty($Variable))) {
        $userdataModAction += "Remove Variable $($Variable)`n"
        $JsonConfig.SetVariable.PSObject.properties | Where-Object {$_.name -notlike $Variable} | ForEach-Object {$SetVariable += @{$_.name = $_.value}}
    } else {$SetVariable = $JsonConfig.setvariable}

    if (-not([string]::IsNullOrEmpty($PSDrive))) {
        $userdataModAction += "Remove PSDrive $($PSDrive)`n"
        $JsonConfig.PSDrive.PSObject.properties | Where-Object {$_.name -notlike "*$PSDrive*"} | ForEach-Object {$SetPSDrive += @{$_.name = $_.value}}
    } else {$SetPSDrive = $JsonConfig.PSDrive}

    if (-not([string]::IsNullOrEmpty($PSAlias))) {
        $userdataModAction += "Remove Alias $($PSAlias)`n"
        $JsonConfig.PSAlias.PSObject.Properties | Where-Object {$_.name -notlike "*$PSAlias*"} | ForEach-Object {$SetPSAlias += @{$_.name = $_.value}}
    } else {$SetPSAlias = $JsonConfig.PSAlias}

    if (-not([string]::IsNullOrEmpty($Command))) { 
        $userdataModAction += "Remove Command $($Command)`n"
        $JsonConfig.Execute.PSObject.Properties | Where-Object {$_.name -notlike "*$Command*"} | ForEach-Object {$SetExecute += @{$_.name = $_.value}}
    } else {$SetExecute = $JsonConfig.Execute}

    if (-not([string]::IsNullOrEmpty($Credential))) { 
        $userdataModAction += "Remove Credential $($Credential)`n"
        $JsonConfig.PSCreds.PSObject.Properties | Where-Object {$_.name -notlike "*$Credential*"} | ForEach-Object {$SetCreds += @{$_.name = $_.value}}
    } else {$SetCreds = $JsonConfig.PSCreds}

    if ($Location) {
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
        SetLocation = $SetLocation
        SetVariable = $SetVariable
        Execute     = $SetExecute
    }

    try {
        $Update | ConvertTo-Json | Set-Content -Path $confile.FullName -Force
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function
