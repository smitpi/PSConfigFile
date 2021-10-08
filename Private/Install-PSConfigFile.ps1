
<#PSScriptInfo

.VERSION 1.0.0

.GUID ec11b3b9-d13e-43c9-8a6d-d42a65016554

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [25/09/2021_02:52] Initital Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 To store your settings 

#> 

Param()

Function Install-PSConfigFile {
    [Cmdletbinding(DefaultParameterSetName='Set2')]
    param (
        [parameter(Mandatory)]
        [System.IO.FileInfo]$ConfigFilePath,
        [Parameter(ParameterSetName = 'Set1')]
        [switch]$UpdatePSModule = $false,
        [Parameter(ParameterSetName = 'Set1')]
        [System.IO.FileInfo]$PathToPSM1File,
        [Parameter(ParameterSetName= 'Set2')]
        [string]$ObjectName,
        [Parameter(ParameterSetName= 'Set2')]
        [string]$ObjectCode,
        [Parameter(ParameterSetName= 'Set2')]
        [validateSet('SetLocation','SetVariable','Execute')]
        [string]$ActionOnImport
    )

$check = Test-Path -Path (Join-Path $ConfigFilePath -ChildPath \PSCustomConfig.json)
if (-not($check)) {
Write-Host "Config File does not exit, creating default settings." -ForegroundColor Magenta

$Userdata = @()
$Userdata = New-Object PSObject -Property @{
	Computer = $env:COMPUTERNAME
    LogonServer   = $env:LOGONSERVER
    OS            = $env:OS
    DomainName    = $env:USERDNSDOMAIN
    Userid        = $env:USERNAME
    LastUpdate    = [DateTimeOffset]::Now
}
$SetLocation = @()
$SetVariable = @()
$Execute = @()

#main
$Data = New-Object PSObject -Property @{
    Userdata     = $Userdata
    SetLocation  = $SetLocation
    SetVariable  = $SetVariable
    Execute      = $Execute
}

$JsonConfig | ConvertTo-Json -Depth 5 | out-file -Append (Join-Path $ConfigFilePath -ChildPath \PSCustomConfig.json) -Verbose -force
}
else {Write-Host "File Exists, Updating existing config." -ForegroundColor Yellow

$Json = Get-Content (Join-Path $ConfigFilePath -ChildPath \PSCustomConfig.json) -Raw | ConvertFrom-Json

function SetVariable {
$Update = @()
$SetVariable = @{}
$members = $Json.SetVariable | Get-Member -MemberType NoteProperty
    foreach ($mem in $members){
        $SetVariable += @{
              $mem.Name = $json.Userdata.$($mem.Name)
         }
    }
     $SetVariable += @{
        $ObjectName = $($ObjectCode)
    }
$Update = [psobject]@{
    Userdata     = $Json.Userdata
    SetLocation  = $Json.SetLocation
    SetVariable  = $SetVariable
    Execute      = $Json.Execute
}

}
function SetLocation {
$Update = @()
$SetLocation = @{}
     $SetLocation += @{
        WorkerDir = $($ObjectCode)
    }
$Update = [psobject]@{
    Userdata     = $Json.Userdata
    SetLocation  = $SetLocation
    SetVariable  = $Json.SetVariable
    Execute      = $Json.Execute
}

}
function Execute {
$Update = @()
$Execute = @{}
$members = $Json.SetVariable | Get-Member -MemberType NoteProperty
    foreach ($mem in $members){
        $Execute += @{
              $mem.Name = $json.Userdata.$($mem.Name)
         }
    }
     $Execute += @{
        $ObjectName = $($ObjectCode)
    }
$Update = [psobject]@{
    Userdata     = $Json.Userdata
    SetLocation  = $Json.SetLocation
    SetVariable  = $Json.SetVariable
    Execute      = $Execute
}

}

if ($ActionOnImport -like 'SetVariable'){SetVariable}
if ($ActionOnImport -like 'SetLocation'){SetLocation}
if ($ActionOnImport -like 'Execute'){Execute}

$Update | ConvertTo-Json -Depth 5 | out-file -Append (Join-Path $ConfigFilePath -ChildPath \PSCustomConfig.json) -Verbose -force

}
}