FROM microsoft/dynamics-nav:2017

RUN  mkdir 'C:\\Run\\mvx'
COPY lsservicecomponents.exe 'C:\\'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
COPY lsclientcomponents.exe 'C:\\'
COPY lsretail.inf 'C:\\'
COPY mvx "C:\\Run\\mvx"
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Write-Host 'Installing LS Service Components' ;  Start-Process "lsservicecomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=lsretail.inf' -Wait -NoNewWindow -Verbose      
RUN Write-Host 'Installing LS Client Components' ;  Start-Process "lsclientcomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=lsretail.inf' -Wait -NoNewWindow -Verbose     
RUN del "lsservicecomponents.exe" ;  del "lsclientcomponents.exe" ;  del lsretail.inf
ENV PATH_WITH_SPACE_CLIENT "C:\\Program Files (x86)\\Microsoft Dynamics NAV\\100\\RoleTailored Client\\Add-ins\\LSRetail\\DD"
ENV PATH_WITH_SPACE_SERVICE "C:\\Program Files\\Microsoft Dynamics NAV\\100\\Service\\Add-ins\\LSRetail\\DD"
RUN mkdir PATH_WITH_SPACE_CLIENT ; \
    mkdir PATH_WITH_SPACE_SERVICE 
COPY DD ${PATH_WITH_SPACE_CLIENT}
COPY DD ${PATH_WITH_SPACE_SERVICE}