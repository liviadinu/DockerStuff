FROM microsoft/dynamics-nav:2018-cu6

RUN  mkdir 'C:\\Run\\mvx'
COPY lsservicecomponents.exe 'C:\\'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
COPY lsclientcomponents.exe 'C:\\'
COPY lsretail.inf 'C:\\'
COPY mvx "C:\\Run\\mvx"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Write-Host 'Installing LS Service Components' ;  Start-Process "lsservicecomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=lsretail.inf' -Wait -NoNewWindow -Verbose      
RUN Write-Host 'Installing LS Client Components' ;  Start-Process "lsclientcomponents.exe" -ArgumentList '/verysilent /supressmsgmoxes /loadinf=lsretail.inf' -Wait -NoNewWindow -Verbose     
RUN del "lsservicecomponents.exe" ;  del "lsclientcomponents.exe" ;  del lsretail.inf
ENV PATH_WITH_SPACE_CLIENT "C:\\Program Files (x86)\\Microsoft Dynamics NAV\\110\\RoleTailored Client\\Add-ins\\LSRetail\\DD"
ENV PATH_WITH_SPACE_SERVICE "C:\\Program Files\\Microsoft Dynamics NAV\\110\\Service\\Add-ins\\LSRetail\\DD"
RUN mkdir PATH_WITH_SPACE_CLIENT ; \
    mkdir PATH_WITH_SPACE_SERVICE 
COPY DD ${PATH_WITH_SPACE_CLIENT}
COPY DD ${PATH_WITH_SPACE_SERVICE}
RUN Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue '"C:\Run\mvx\DynamicsNAV2018ServerAddins"' -Destination ${PATH_WITH_SPACE_CLIENT} ; \
	Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue '"C:\Run\mvx\DynamicsNAV2018ServerDLL"' -Destination ${PATH_WITH_SPACE_CLIENT}
RUN Remove-Item '"C:\Run\mvx\DynamicsNAV2018ServerDLL"' -Force -Recurse -Verbose ; \ 
	Remove-Item '"C:\Run\mvx\DynamicsNAV2018ServerAddins"' -Force -Recurse -Verbose 
	
	
Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue "C:\Program Files\Microsoft Dynamics NAV\110\Service\" -Destination "C:\Run\Program Files\110\RoleTailored Client\"
Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue "C:\Program Files\Microsoft Dynamics NAV\110\Service\Add-ins\" -Destination "C:\Run\Program Files\110\RoleTailored Client\Add-ins\"