FROM mcr.microsoft.com/windows/servercore:10.0.18362.295 AS base

LABEL maintainer "LD"

# Download Links:
ENV sql_express_download_url "https://go.microsoft.com/fwlink/?linkid=829176"

ENV sa_password="_" \
    attach_dbs="[]" \
    ACCEPT_EULA="_" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# make install files accessible
COPY start.ps1 /
WORKDIR /

RUN Invoke-WebRequest -Uri $env:sql_express_download_url -OutFile sqlexpress.exe ; \
        Start-Process -Wait -FilePath .\sqlexpress.exe -ArgumentList /qs, /x:setup ; \
        .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=SQLEXPRESS /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
        Remove-Item -Recurse -Force sqlexpress.exe, setup

RUN stop-service MSSQL`$SQLEXPRESS ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\' -name LoginMode -value 2 ;

CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose

# escape=`
# using vNext image
FROM base
 
# create directory within SQL container for database files
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir 'C:\\SQLServer'
 
#copy the database files from host to container
COPY MVDEVBC.mdf "C:\\SQLServer"
COPY MVDEVBC.ldf "C:\\SQLServer"

ENV ACCEPT_EULA=Y
 
ENV attach_dbs="[{'dbName':'MVDEVBC','dbFiles':['C:\\\\SQLServer\\\\MVDEVBC.mdf','C:\\\\SQLServer\\\\MVDEVBC.ldf']}]"

EXPOSE 1433 443