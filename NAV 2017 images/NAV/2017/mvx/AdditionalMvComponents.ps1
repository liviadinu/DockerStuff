$mvxpath = "C:\run\mvx\CompInstall.txt"
[bool]$isRestarting = [System.IO.File]::Exists($mvxpath)
if(!$isRestarting){
	$serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\100\Service").FullName
	if (Test-Path "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1") {
		Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1" -wa SilentlyContinue
	} else {
		Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.dll" -wa SilentlyContinue
	}

	$roleTailoredClientFolder = (Get-Item "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client").FullName
	if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1") {
		Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1" -wa SilentlyContinue
	}
	
	$var = Get-NAVCompany -ServerInstance NAV | Where-Object {$_.CompanyName -eq 'AutoTest'} | Out-String
	[bool]$nExists = $var -eq ''
	if ($nExists) {
	   Write-Host 'Creating AutoTest Company...'
	   New-NAVCompany -ServerInstance NAV -CompanyName 'AutoTest'}
}	

