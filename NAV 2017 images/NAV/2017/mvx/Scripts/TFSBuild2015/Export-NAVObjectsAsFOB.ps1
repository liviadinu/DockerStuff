Param (
	[String]$Server=$env:NAV_SQLSERVER,
	[String]$Database=$env:NAV_SQLSERVERDB,
	[String]$ResultFob=(Join-Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY ($env:BUILD_BUILDNUMBER+'.fob')) ,
	[String]$NavIde=$env:NAV_NAVIDEPATH,
	[String]$LogFolder=$env:BUILD_STAGINGDIRECTORY
)
if (Test-Path $env:BUILD_SOURCESDIRECTORY\setup.xml) {
    $config = (. "$PSScriptRoot\..\Get-NAVGITSetup.ps1" -SetupFile "$env:BUILD_SOURCESDIRECTORY\setup.xml")
}
$env:NavIdePath | Write-Host
Import-Module -Name NVR_NAVScripts -DisableNameChecking -Force

NVR_NAVScripts\Export-NAVApplicationObject -Server $Server -Database $Database -Path $ResultFob -Filter 'Compiled=1' -NavIde $NavIde -LogFolder $LogFolder

