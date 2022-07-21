
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
        [System.IO.FileInfo]$OtherConfigFile = $PSConfigFile
    )

    if ($ShowLastInvokeOutput) { $outputfile = $PSConfigFileOutput }
    else {
        try {
            if ([string]::IsNullOrEmpty($OtherConfigFile)) {
                Add-Type -AssemblyName System.Windows.Forms
                $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
                $null = $FileBrowser.ShowDialog()
                $confile = Get-Item $FileBrowser.FileName
            } else {
                try {
                    $confile = Get-Item $OtherConfigFile -ErrorAction stop
                } catch {
                    Add-Type -AssemblyName System.Windows.Forms
                    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'JSON | *.json' }
                    $null = $FileBrowser.ShowDialog()
                    $confile = Get-Item $FileBrowser.FileName
                }
            }

            $outputfile = [System.Collections.Generic.List[string]]::new()
            $outputfile.Add('')

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution Start")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $JSONParameter = (Get-Content $confile.FullName | Where-Object { $_ -notlike "*`"Default`"*" }) | ConvertFrom-Json
            if ([string]::IsNullOrEmpty($JSONParameter)) { Write-Error 'Valid Parameters file not found'; break }
            $outputfile.Add("<b>[$((Get-Date -Format HH:mm:ss).ToString())] Using PSCustomConfig file: $($confile.fullname)")

            #region User Data
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Details of Config File:")
            $JSONParameter.Userdata.PSObject.Properties | Where-Object {$_.name -notlike 'ModifiedData' } | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            #endregion

            #region User Data Modified
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Config File Modified Data:")
            $JSONParameter.Userdata.ModifiedData.PSObject.Properties | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            #endregion

            #Set Variables
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Default Variables:")
            $JSONParameter.SetVariable.PSObject.Properties | Sort-Object -Property name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }
            $PSConfigFilePathoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFilePath', $(($confile.Directory).FullName)
            $outputfile.Add($PSConfigFilePathoutput)
            $PSConfigFileoutput = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'PSConfigFile', $(($confile).FullName)
            $outputfile.Add($PSConfigFileoutput)

            # Set PsDrives
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating PSDrives:")
            $JSONParameter.PSDrive.PSObject.Properties | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value.root)
                $outputfile.Add($output)
            }

            # Set Alias
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Custom Aliases: ")
            $JSONParameter.PSAlias.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }

            #region Creds
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Creating Credentials: ")
            $JSONParameter.PSCreds.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $username = $_.value.split(']-')[0].Replace('[', '')
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($username)
                $outputfile.Add($output)
            }
            #endregion

            # Execute Commands
            $outputfile.Add('<h>  ')
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Executing Custom Commands: ")
            $JSONParameter.execute.PSObject.Properties | Select-Object name, value | Sort-Object -Property Name | ForEach-Object {
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f $($_.name), $($_.value)
                $outputfile.Add($output)
            }

            # Set Location
            if ([bool]$JSONParameter.SetLocation.WorkerDir -like $true) {
                $outputfile.Add('<h>  ')
                $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] Setting Working Directory: ")
                $output = "<b>[$((Get-Date -Format HH:mm:ss).ToString())]  {0,-28}: {1,-20}" -f 'Location:', $($($JSONParameter.SetLocation.WorkerDir))
                $outputfile.Add($output)
            }

            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] #######################################################")
            $outputfile.Add("<h>[$((Get-Date -Format HH:mm:ss).ToString())] PSConfigFile Execution End")
        } catch {
            Write-Warning $_.Exception
            Write-Warning $_.Exception.message
        }
    }

    foreach ($line in $outputfile) {
        if ($line -like '<h>*') { Write-Color $line.Replace('<h>', '') -Color DarkCyan }
        if ($line -like '<b>*') { Write-Color $line.Replace('<b>', '') -Color DarkGray }
        if ($line -like '<w>*') { Write-Color $line.Replace('<w>', '') -Color DarkYellow }
        if ($line -like '<e>*') { Write-Color $line.Replace('<e>', '') -Color DarkRed }
    }

} #end Function