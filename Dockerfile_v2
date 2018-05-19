FROM microsoft/dynamics-nav:2017

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; #(nop)"]

RUN  mkdir 'C:\\Run\\mvx' ; \
     mkdir 'C:\\Run\\Repo' 
	 
COPY mvx "C:\\Run\\mvx"

RUN  Write-Host "Installing LS Retail Components..." ; \
	 Set-ExecutionPolicy Bypass -Scope Process -Force ; \ 
	 Start-Process "C:\run\mvx\LS Nav 10.10.00.555 Service Components.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=C:\run\mvx\lsretail.inf' -Wait -NoNewWindow ; \
	 Start-Process "C:\run\mvx\LS Nav 10.10.00.555 Client Components.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=C:\run\mvx\lsretail.inf' -Wait -NoNewWindow -Verbose ; \ 
	 Write-Host "Copying LS Retail .dlls to Add-ins folder..." ; \ 
	 Copy-Item -Path "C:\run\mvx\DD" -Destination '"C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\"' -Recurse ; \
	 Copy-Item -Path "C:\run\mvx\DD\" -Destination '"C:\Program Files\Microsoft Dynamics NAV\100\Service\Add-ins\"' -Recurse ; \
     Copy-Item -Path "C:\run\mvx\DD\*.dll" -Destination '"C:\Program Files\Microsoft Dynamics NAV\100\Service\Add-ins\"' -Recurse -Filter "*.dll" ; \
	 Copy-Item -Path '"C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\"' -Destination "C:\run\my\" -Recurse ; \	 
     Remove-Item -Path '"C:\run\mvx\LS Nav 10.10.00.555 Service Components.exe"' ; \
 	 Remove-Item -Path '"C:\run\mvx\LS Nav 10.10.00.555 Client Components.exe"' ; \
	 Copy-Item -Path '"C:\run\mvx\DD\*.dll"' -Destination '"C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Add-ins\"' -Recurse -Filter '*.dll' ; \