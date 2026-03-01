
    [Cmdletbinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile', HelpURI = 'https://smitpi.github.io/PSConfigFile/Set-PSConfigFileExecution')]
    param (
        [Parameter(ParameterSetName = 'Profile')]
        [validateSet('AddScript', 'RemoveScript')]
        [string]$PSProfile = 'AddScript',
        [switch]$DisplayOutput
    )

    try {
        $confile = Get-Item $PSConfigFile -ErrorAction stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'XML | *.xml' }
        $null = $FileBrowser.ShowDialog()
        $confile = Get-Item $FileBrowser.FileName
    }
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        $module = Get-Module PSConfigFile
        if (![bool]$module) { $module = Get-Module PSConfigFile -ListAvailable }

        if ($DisplayOutput) {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`"  -DisplayOutput #PSConfigFile

"@
        } else {
            $ToAppend = @"

#PSConfigFile
`$PSConfigFileModule = Get-ChildItem `"$((Join-Path ((Get-Item $Module.ModuleBase).Parent).FullName '\*\PSConfigFile.psm1'))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1 #PSConfigFile
Import-Module `$PSConfigFileModule.FullName -Force #PSConfigFile
Invoke-PSConfigFile -ConfigFile `"$($confile.FullName)`" #PSConfigFile

"@
        }


        if ($PSProfile -like 'AddScript') {

            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8
                Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }
        if ($PSProfile -like 'RemoveScript') {
            $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
            $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
            $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
            $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
            foreach ($file in $files) {	
                $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSConfigFile*'}
                $tmp | Set-Content -Path $file.FullName -Force
                Write-Host '[Removed]' -NoNewline -ForegroundColor Yellow; Write-Host ' From Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
            }
        }

    }

