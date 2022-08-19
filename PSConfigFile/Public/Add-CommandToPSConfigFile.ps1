
<#PSScriptInfo

.VERSION 1.1.4

.GUID 98459c57-e214-4a9f-b523-efa2329a0340

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
Updated [14/10/2021_19:31] Added PSDrive Script
Updated [13/11/2021_16:30] Added Function Script

.PRIVATEDATA

#>









<#

.DESCRIPTION
Add a command to the config file

#>


<#
.SYNOPSIS
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.DESCRIPTION
Adds a command or script block to the config file, to be executed every time the invoke function is called.

.PARAMETER ScriptBlockName
Name for the script block

.PARAMETER ScriptBlock
The commands to be executed

.EXAMPLE
Add-CommandToPSConfigFile -ScriptBlockName DriveC -ScriptBlock "Get-ChildItem c:\"

#>
Function Add-CommandToPSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Add-CommandToPSConfigFile')]
    PARAM(
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlockName,
        [ValidateNotNullOrEmpty()]
        [string]$ScriptBlock
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }

    $Json = Get-Content $confile.FullName -Raw | ConvertFrom-Json
    $userdata = [PSCustomObject]@{
        Owner             = $json.Userdata.Owner
        CreatedOn         = $json.Userdata.CreatedOn
        PSExecutionPolicy = $json.Userdata.PSExecutionPolicy
        Path              = $json.Userdata.Path
        Hostname          = $json.Userdata.Hostname
        PSEdition         = $json.Userdata.PSEdition
        OS                = $json.Userdata.OS
        ModifiedData      = [PSCustomObject]@{
            ModifiedDate   = (Get-Date -Format u)
            ModifiedUser   = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
            ModifiedAction = "Add Command $($ScriptBlockName)"
            Path           = "$confile"
            Hostname       = ([System.Net.Dns]::GetHostEntry(($($env:COMPUTERNAME)))).HostName
        }
    }

    $Update = @()
    [System.Collections.generic.List[PSObject]]$ExecuteObject = @()
    
    if ($Json.Execute.psobject.Properties.name -like 'Default' -and
        $Json.Execute.psobject.Properties.value -like 'Default') {
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = 0
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    } else {
        $Json.Execute | ForEach-Object {$ExecuteObject.Add($_)}
        $IndexID = $ExecuteObject.IndexID | Sort-Object -Descending | Select-Object -First 1
        $ExecuteObject.Add([PSCustomObject]@{
                IndexID     = ($IndexID + 1 )
                Name        = $ScriptBlockName
                ScriptBlock = $ScriptBlock
            })
    }
    $Update = [psobject]@{
        Userdata    = $Userdata
        PSDrive     = $Json.PSDrive
        PSFunction  = $Json.PSFunction
        PSCreds     = $Json.PSCreds
        PSDefaults  = $Json.PSDefaults
        SetLocation = $Json.SetLocation
        SetVariable = $Json.SetVariable
        Execute     = $ExecuteObject
    }
    try {
        $Update | ConvertTo-Json -Depth 5 | Set-Content -Path $confile.FullName -Force
        Write-Output 'Command added'
        Write-Output "ConfigFile: $($confile.FullName)"
    } catch { Write-Error "Error: `n $_" }



} #end Function
