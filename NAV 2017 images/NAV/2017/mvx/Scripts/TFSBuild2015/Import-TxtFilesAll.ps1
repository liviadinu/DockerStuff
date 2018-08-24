﻿param (
    #Object files from which to update. Should be complete set of objects
    [Parameter(ValueFromPipelinebyPropertyName=$True)]
    [String]$Files=(Join-Path $env:BUILD_SOURCESDIRECTORY $env:NAV_OBJECTFILES),
    #SQL Server address
    [Parameter(ValueFromPipelinebyPropertyName=$True)]
    [String]$Server=$env:NAV_SQLSERVER,
    #SQL Database to update
    [Parameter(ValueFromPipelinebyPropertyName=$True)]
    [String]$Database=$env:NAV_SQLSERVERDB,
    #LogFolder
    [Parameter(ValueFromPipelinebyPropertyName=$True)]
    [String]$LogFolder=$env:BUILD_STAGINGDIRECTORY
)
if (Test-Path $env:BUILD_SOURCESDIRECTORY\setup.xml) {
    $config = (. "$PSScriptRoot\..\Get-NAVGITSetup.ps1" -SetupFile "$env:BUILD_SOURCESDIRECTORY\setup.xml")
}
$env:NavIdePath | Write-Host

Import-Module -Name NVR_NAVScripts -DisableNameChecking -Force
Import-Module -Name CommonPSFunctions
Import-Module (Get-NAVAdminModuleName)

$ProgressPreference="SilentlyContinue"
if ($env:NAV_FORCEIMPORTALL -eq 1) {
  Update-NAVApplicationFromTxt -Files $Files -Server $Server -Database $Database -LogFolder $LogFolder -MarkToDelete -NoProgress -All
} else {
  Update-NAVApplicationFromTxt -Files $Files -Server $Server -Database $Database -LogFolder $LogFolder -MarkToDelete -NoProgress
}
$ProgressPreference="Continue"
