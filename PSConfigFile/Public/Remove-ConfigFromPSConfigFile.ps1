
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

.PARAMETER Config
Which config item to remove.

.PARAMETER Value
The value of the config item to filter out.

.EXAMPLE
Remove-ConfigFromPSConfigFile -Config PSDrive -Value ProdMods

#>
Function Remove-ConfigFromPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Remove-ConfigFromPSConfigFile')]
    PARAM(
        [ValidateSet('Variable', 'PSDrive', 'Function', 'Command', 'Credential', 'PSDefaults', 'Location')]
        [string]$Config,
        [string]$Value
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
    $userdataModAction = 'Removed Config: '

    if ($Config -like 'Variable') {
        $userdataModAction += "Removed Variable $($Value)`n"
        $SetVariable = $JsonConfig.SetVariable | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetVariable = $JsonConfig.setvariable}

    if ($Config -like 'PSDrive') {
        $userdataModAction += "Removed PSDrive $($Value)`n"
        $SetPSDrive = $JsonConfig.PSDrive | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSDrive = $JsonConfig.PSDrive}

    if ($Config -like 'Function') {
        $userdataModAction += "Removed Function $($Value)`n"
        $SetPSFunction = $JsonConfig.PSFunction | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSFunction = $JsonConfig.PSFunction}

    if ($Config -like 'Command') { 
        $userdataModAction += "Removed Command $($Value)`n"
        $SetExecute = $JsonConfig.Execute | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetExecute = $JsonConfig.Execute}

    if ($Config -like 'Credential') {
        $userdataModAction += "Removed Credential $($Value)`n"
        $SetCreds = $JsonConfig.PSCreds | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetCreds = $JsonConfig.PSCreds}

    if ($Config -like 'PSDefaults') {
        $userdataModAction += "Removed PSDefaults $($Value)`n"
        $SetPSDefaults = $JsonConfig.PSDefaults | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSDefaults = $JsonConfig.PSDefaults}

    if ($Config -like 'Location') {
        $userdataModAction += "Removed Location`n"
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
        PSFunction  = $SetPSFunction
        PSCreds     = $SetCreds
        PSDefaults  = $SetPSDefaults
        SetLocation = $SetLocation
        SetVariable = $SetVariable
        Execute     = $SetExecute
    }
    try {
        $Update | ConvertTo-Json | Set-Content -Path $confile.FullName -Force
        Write-Output "$(($userdataModAction | Out-String).Trim())"
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function
