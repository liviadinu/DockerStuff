FROM microsoft/dynamics-nav:2018-cu8-ltsc2016

RUN  mkdir 'C:\\Run\\mvx'
COPY lsservicecomponents.exe 'C:\\'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
COPY lsclientcomponents.exe 'C:\\'
COPY client.inf 'C:\\'
COPY service.inf 'C:\\'
COPY mvx "C:\\Run\\mvx"
COPY K3VeriFoneSerialInterfaceDLL 'C:\\'

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Start-Process '"C:\\Windows\\SysWOW64\\regsvr32.exe"'   -ArgumentList '/s /i C:\\K3VeriFoneSerialInterfaceDLL\\K3VeriFoneSerialInterface.dll' -Wait -NoNewWindow -Verbose
RUN Write-Host 'Installing LS Service Components' ;  Start-Process "lsservicecomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=service.inf' -Wait -NoNewWindow -Verbose      
RUN Write-Host 'Installing LS Client Components' ;  Start-Process "lsclientcomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=client.inf' -Wait -NoNewWindow -Verbose     
RUN del "lsservicecomponents.exe" ;  del "lsclientcomponents.exe" ;  del service.inf ; del client.inf    
RUN Move-Item -Path '"C:\\Run\\mvx\\KitchenServiceClient"' -Destination '"C:\\Program Files (x86)\\Microsoft Dynamics NAV\\110\\RoleTailored Client\\Add-ins\\LSRetail\\"' -Force -Verbose
ENV PATH_WITH_SPACE_CLIENT "C:\\Program Files (x86)\\Microsoft Dynamics NAV\\110\\RoleTailored Client\\Add-ins\\LSRetail\\DD"
ENV PATH_WITH_SPACE_SERVICE "C:\\Program Files\\Microsoft Dynamics NAV\\110\\Service\\Add-ins\\LSRetail\\DD"
COPY DD ${PATH_WITH_SPACE_CLIENT}
COPY DD ${PATH_WITH_SPACE_SERVICE}
COPY K3VeriFoneSerialInterfaceDLL ${PATH_WITH_SPACE_CLIENT}
COPY K3VeriFoneSerialInterfaceDLL ${PATH_WITH_SPACE_SERVICE}

EXPOSE 587 21 25 5000 5001