FROM microsoft/dynamics-nav:2018

RUN  mkdir 'C:\\Run\\mvx' ; \
	 mkdir 'C:\\DynamicsNAV2018ServerAddins' ; \
	 mkdir 'C:\\DynamicsNAV2018ServerDLL'
	 COPY mvx 'C:\\Run\\mvx'
	 
COPY DynamicsNAV2018ServerAddins 'C:\\DynamicsNAV2018ServerAddins'
COPY DynamicsNAV2018ServerDLL 'C:\\DynamicsNAV2018ServerDLL'
COPY lsservicecomponents.exe 'C:\\'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
COPY lsclientcomponents.exe 'C:\\'
COPY lsretail.inf 'C:\\'


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
RUN del "lsservicecomponents.exe" ; \
	del "lsclientcomponents.exe" ; \
	del lsretail.inf ; \
	Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue "C:\DynamicsNAV2018ServerAddins" -Destination ${PATH_WITH_SPACE_CLIENT} ; \
	Copy-Item -Recurse -Verbose -ErrorAction SilentlyContinue 'C:\DynamicsNAV2018ServerDLL' -Destination ${PATH_WITH_SPACE_CLIENT} ; \	
    Remove-Item '"C:\DynamicsNAV2018ServerDLL"' -Force -Recurse -Verbose ; \ 
	Remove-Item '"C:\DynamicsNAV2018ServerAddins"' -Force -Recurse -Verbose ; \ 
	Remove-Item '"C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Add-ins\LSRetail\POS\Newtonsoft.Json.dll"' -Force -Verbose ; \ 
    Remove-Item '"C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Add-ins\LSRetail\Newtonsoft.Json"' -Recurse -Force -Verbose ; \
    Remove-Item '"C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Add-ins\LSRetail\LSRecommend\System.Spatial.dll"' -Force -Verbose 
