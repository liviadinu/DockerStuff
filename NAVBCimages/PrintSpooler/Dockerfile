FROM mcr.microsoft.com/windows:1903
  	  
COPY     lsclientcomponents.exe 'C:\\'                                             
COPY     lsservicecomponents.exe 'C:\\'
COPY     client.inf 'C:\\'
COPY     service.inf 'C:\\'

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Install-WindowsFeature Print-Server ; Set-Service spooler -StartupType Automatic ; Start-Service spooler ; Get-Service spooler ; Get-Printer

RUN Write-Host 'Installing LS Service Components' ;  Start-Process "lsservicecomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=service.inf' -Wait -NoNewWindow -Verbose
RUN Write-Host 'Installing LS Client Components' ;  Start-Process "lsclientcomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=client.inf' -Wait -NoNewWindow -Verbose   
RUN del "lsservicecomponents.exe" ;  del "lsclientcomponents.exe" ;  del service.inf ; del client.inf

RUN	Write-Host 'Starting LS HardwareStation Service...' ; Set-Service -Name 'LS HardwareStation Service' -StartupType Automatic ; Start-Service -Name 'LS HardwareStation Service' ; Get-Service -Name 'LS HardwareStation Service'