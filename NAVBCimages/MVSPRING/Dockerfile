FROM mygeneric
  	  
RUN  mkdir 'C:\\Run\\mvx'
RUN  mkdir  'C:\\temp\\'
COPY navdvd "C:\\navdvd"	
COPY mvx 'C:\\Run\\mvx'
COPY ECO 'C:\\temp\\ECO'
COPY ECO 'C:\\ECO'
COPY     lsclientcomponents.exe 'C:\\'                                             
COPY     lsservicecomponents.exe 'C:\\'
COPY     client.inf 'C:\\'
COPY     service.inf 'C:\\'

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Write-Host 'Installing LS Service Components' ;  Start-Process "lsservicecomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=service.inf' -Wait -NoNewWindow -Verbose
RUN Write-Host 'Installing LS Client Components' ;  Start-Process "lsclientcomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=client.inf' -Wait -NoNewWindow -Verbose   
RUN del "lsservicecomponents.exe" ;  del "lsclientcomponents.exe" ;  del service.inf ; del client.inf


EXPOSE 587 21 25 80 8088 8082 8711

LABEL legal="K3" \
      created="23/09/2019" \
      nav="BusinessCentralCustom" \
      cu="04" \
      country="W1" \
      version="14.5.35970.0" \
      platform="14.0.35916.0" \
      ls="14.01"	  