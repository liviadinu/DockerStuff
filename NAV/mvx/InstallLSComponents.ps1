$lspath = "C:\run\mvx\LSInstall.txt"
[bool]$isRestarting = [System.IO.File]::Exists($lspath)
if(!$isRestarting){
	Write-Host 'Installing LS Retail Components...'
	Set-ExecutionPolicy Bypass -Scope Process -Force 
	#Start-Process "C:\run\mvx\LS Nav 10.10.00.555 Service Components.exe" -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /LOADINF=C:\run\mvx\lsretail.inf' -Wait -NoNewWindow
	#Start-Process "C:\run\mvx\LS Nav 10.10.00.555 Client Components.exe" -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /LOADINF=C:\run\mvx\lsretail.inf' -Wait -NoNewWindow
 
	iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco
	choco feature enable -n allowGlobalConfirmation
	cinst "C:\run\mvx\lsclientcomp.10.10.nupkg"
	cinst "C:\run\mvx\lsservicecomp.10.10.nupkg"
	Write-Host 'Copying LS Retail .dlls to Add-ins folder...'

	Copy-Item -Path "C:\run\mvx\DD" -Destination "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\" -Recurse
	Copy-Item -Path "C:\run\mvx\DD\*.dll" -Destination "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\" -Recurse -Filter *.dll
	Copy-Item -Path "C:\run\mvx\DD\" -Destination "C:\Program Files\Microsoft Dynamics NAV\100\Service\Add-ins\" -Recurse
	Copy-Item -Path "C:\run\mvx\DD\*.dll" -Destination "C:\Program Files\Microsoft Dynamics NAV\100\Service\Add-ins\" -Recurse -Filter *.dll

	Copy-Item -Path "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\" -Destination "C:\run\my\" -Recurse
	Copy-Item -Path "C:\run\mvx\Prompt.ps1" -Destination "C:\run\Prompt.ps1" -Force
    New-Item "C:\run\mvx\LSInstall.txt" -ItemType file
}