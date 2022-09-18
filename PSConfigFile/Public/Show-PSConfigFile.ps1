
<#PSScriptInfo

.VERSION 0.1.0

.GUID 781274ac-332b-4346-bc72-2a586fa20ed6

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
Created [13/11/2021_21:22] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Display what's configured in the config file

#>


<#
.SYNOPSIS
Display what's configured in the config file.

.DESCRIPTION
Display what's configured in the config file. But doesn't execute the commands

.PARAMETER ShowLastInvokeOutput
Display the output of the last Invoke-PSConfigFile execution.

.PARAMETER OtherConfigFile
Path to a previously created config file.

.EXAMPLE
Show-PSConfigFile -ShowLastInvokeOutput

#>
Function Show-PSConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSConfigFile/Show-PSConfigFile')]
    param (
        [switch]$ShowLastInvokeOutput,
        [System.IO.FileInfo]$OtherConfigFile
    )

    if ($ShowLastInvokeOutput) { $outputfile = $PSConfigFileOutput }
    else {
        try {
            if ([string]::IsNullOrEmpty($OtherConfigFile)) {
                Add-Type -AssemblyName System.Windows.Forms
                $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
                $null = $FileBrowser.ShowDialog()
                $confile = Get-Item $FileBrowser.FileName
            } else {
                try {
                    $confile = Get-Item $OtherConfigFile -ErrorAction stop
                } catch {
                    Add-Type -AssemblyName System.Windows.Forms
                    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
                    $null = $FileBrowser.ShowDialog()
                    $confile = Get-Item $FileBrowser.FileName
                }
            }
            #region Import xml
            $XMLData = Import-Clixml -Path $confile.FullName
            if ([string]::IsNullOrEmpty($XMLData)) { Write-Error 'Valid Parameters file not found'; break }
            $outputfile = [System.Collections.Generic.List[string]]::new()
            $outputfile.Add('')

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Details")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ##############################################################")
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Module Version', "$((Get-Module PSConfigFile -ListAvailable | Sort-Object -Property Version -Descending)[0].Version)"
            $outputfile.Add($output)
            $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())] {0,-28}: {1,-20}" -f 'Showing PSCustomConfig file', "$($confile.fullname)"
            $outputfile.Add($output)
            #endregion

            #region User Data
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] ################### Config File: Meta Data ###################")
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creation Data:")
                $XMLData.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error user data: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error user data: Message:$($_.Exception.Message)")}
            #endregion

            #region User Data Modified
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())]  Modification Data:")
                $XMLData.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]`t`t{0,-28}: {1,-20}" -f $($_.name), $($_.value)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Modified: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Modified: Message:$($_.Exception.Message)")}
            #endregion

            #region Set Variables
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #################### Config File Details: ####################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Variables to be created:")
            foreach ($SetVariable in  ($XMLData.SetVariable | Where-Object {$_ -notlike $null})) {
                $VarMember = $SetVariable | Get-Member -MemberType NoteProperty, Property
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($VarMember.name), $($SetVariable.$($VarMember.name))
                $outputfile.Add($output)
            }
            $PSConfigFilePathoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $outputfile.Add($PSConfigFilePathoutput)
            $PSConfigFileoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $outputfile.Add($PSConfigFileoutput)
            #endregion

            #region Set PsDrives
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSDrives to be created:")
                foreach ($SetPSDrive in  ($XMLData.PSDrive | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSDrive.Name), $($SetPSDrive.root)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error PSDrive: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error PSDrive: Message:$($_.Exception.Message)")}
            #endregion

            #region Set Function
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Functions to be created: ")
                foreach ($SetPSFunction in  ($XMLData.PSFunction | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($SetPSFunction.name), $($SetPSFunction.Command)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Function: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error Function: Message:$($_.Exception.Message)")}
            #endregion

            #region Creds
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Credentials to be created: ")
                foreach ($Cred in ($XMLData.PSCreds | Where-Object {$_.Edition -like "*$($PSVersionTable.PSEdition)*"})) {
                    $credname = $Cred.Name
                    $username = $Cred.UserName
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($credname), "(PS$($PSVersionTable.PSEdition)) $($username)"
                    $outputfile.Add($output)
            }
            #endregion

            #region Set PSDefaults
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSDefaultParameterValues to be created:")
            foreach ($PSD in  $XMLData.PSDefaults) {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  Function:{0,-20} Parameter:{1,-30}: {2}" -f $($PSD.Name.Split(':')[0]), $($PSD.Name.Split(':')[1]), $($PSD.Value)
                $outputfile.Add($output)
            }
            #endregion

            #region Set Location
            try {
                if (-not([string]::IsNullOrEmpty($XMLData.SetLocation))) {
                    $outputfile.Add('<h>  ')
                    $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Working Directory to be set: ")
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($XMLData.SetLocation.WorkerDir))
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Location: `n`tMessage:$($_.Exception.Message)"; $PSConfigFileOutput.Add("<e>Error Creds: Message:$($_.Exception.Message)")}
            #endregion

            #region Execute Commands
            try {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Commands to be executed: ")
                foreach ($execute in  ($XMLData.execute | Where-Object {$_ -notlike $null})) {
                    $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($execute.name), $($execute.ScriptBlock)
                    $outputfile.Add($output)
                }
            } catch {Write-Warning "Error Commands: `n`tMessage:$($_.Exception.Message)"; $outputfile.Add("<e>Error Commands: Message:$($_.Exception.Message)")}
            #endregion

            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Details End")
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
    }

    foreach ($line in $outputfile) {
        if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
        if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
        if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
        if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
    }

} #end Function