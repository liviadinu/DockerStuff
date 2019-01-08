# escape=`
# using vNext image
FROM microsoft/mssql-server-windows-express
 
# create directory within SQL container for database files
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir 'C:\\SQLServer'
 
#copy the database files from host to container
COPY Bahrain2018_Data.mdf "C:\\SQLServer"
COPY Bahrain2018_1_Data.ndf "C:\\SQLServer"
COPY Bahrain2018_Log.ldf "C:\\SQLServer"

ENV ACCEPT_EULA=Y
 
ENV attach_dbs="[{'dbName':'Bahrain2018','dbFiles':['C:\\\\SQLServer\\\\Bahrain2018_Data.mdf','C:\\\\SQLServer\\\\Bahrain2018_1_Data.ndf','C:\\\\SQLServer\\\\Bahrain2018_Log.ldf']}]"