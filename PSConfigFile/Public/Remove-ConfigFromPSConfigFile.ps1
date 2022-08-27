
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
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    [System.Collections.Generic.List[pscustomobject]]$XMLData = @()
    $XMLData.Add((Import-Clixml -Path $confile.FullName))
    $userdataModAction = 'Removed Config: '

    if ($Config -like 'Variable') {
        $userdataModAction += "Removed Variable $($Value)`n"
        $SetVariable = $XMLData.setvariable | Where-Object {$_ -notlike "*$($Value)*"}
    } else {$SetVariable = $XMLData.setvariable}

    if ($Config -like 'PSDrive') {
        $userdataModAction += "Removed PSDrive $($Value)`n"
        $SetPSDrive = $XMLData.PSDrive | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSDrive = $XMLData.PSDrive}

    if ($Config -like 'Function') {
        $userdataModAction += "Removed Function $($Value)`n"
        $SetPSFunction = $XMLData.PSFunction | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSFunction = $XMLData.PSFunction}

    if ($Config -like 'Command') { 
        $userdataModAction += "Removed Command $($Value)`n"
        $SetExecute = $XMLData.Execute | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetExecute = $XMLData.Execute}

    if ($Config -like 'Credential') {
        $userdataModAction += "Removed Credential $($Value)`n"
        $SetCreds = $XMLData.PSCreds | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetCreds = $XMLData.PSCreds}

    if ($Config -like 'PSDefaults') {
        $userdataModAction += "Removed PSDefaults $($Value)`n"
        $SetPSDefaults = $XMLData.PSDefaults | Where-Object {$_.name -notlike "*$Value*"}
    } else {$SetPSDefaults = $XMLData.PSDefaults}

    if ($Config -like 'Location') {
        $userdataModAction += "Removed Location`n"
        $SetLocation = @{}
    } else {$SetLocation = $XMLData.SetLocation}
    
    $userdata = [PSCustomObject]@{
        Owner             = $XMLData.Userdata.Owner
        CreatedOn         = $XMLData.Userdata.CreatedOn
        PSExecutionPolicy = $XMLData.Userdata.PSExecutionPolicy
        Path              = $XMLData.Userdata.Path
        Hostname          = $XMLData.Userdata.Hostname
        PSEdition         = $XMLData.Userdata.PSEdition
        OS                = $XMLData.Userdata.OS
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
        PSDrive     = ($SetPSDrive | Where-Object {$_ -notlike $null})
        PSFunction  = ($SetPSFunction | Where-Object {$_ -notlike $null})
        PSCreds     = ($SetCreds | Where-Object {$_ -notlike $null})
        PSDefaults  = ($SetPSDefaults | Where-Object {$_ -notlike $null})
        SetLocation = ($SetLocation | Where-Object {$_ -notlike $null})
        SetVariable = ($SetVariable | Where-Object {$_ -notlike $null})
        Execute     = ($SetExecute | Where-Object {$_ -notlike $null})
    }
    try {
        Rename-Item -Path $confile -NewName "Outdated_PSConfigFile_$(Get-Date -Format yyyyMMdd_HHmm).xml" -Force
        $Update | Export-Clixml -Depth 10 -Path $confile.FullName -NoClobber -Encoding utf8 -Force
        Write-Output "$(($userdataModAction | Out-String).Trim())"
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }
} #end Function


