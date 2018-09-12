# escape=`
# using vNext image
FROM microsoft/mssql-server-windows-express
 
# create directory within SQL container for database files
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir 'C:\\SQLServer'
 
#copy the database files from host to container
COPY Lithuania2017_Data.mdf "C:\\SQLServer"
COPY Lithuania2017_1_Data.ndf "C:\\SQLServer"
COPY Lithuania2017_Log.ldf "C:\\SQLServer"

ENV ACCEPT_EULA=Y
 
ENV attach_dbs="[{'dbName':'Lithuania2017','dbFiles':['C:\\\\SQLServer\\\\Lithuania2017_Data.mdf','C:\\\\SQLServer\\\\Lithuania2017_1_Data.ndf','C:\\\\SQLServer\\\\Lithuania2017_Log.ldf']}]"