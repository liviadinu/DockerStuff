function Update-GitFromMvContainer {
Param(
  [Parameter(Mandatory=$true)]
  [string]$navContainerName)

$envContent = docker inspect --format='{{ .Config.Env}}' $navContainerName
$dbsFormat = '(?<=databaseServer=).*?(?=\s)'
$dbServer = [regex]::Match($envContent,$dbsFormat)

$dbFormat ='(?<=databaseName=).*?(?=\s)'
$dbName = [regex]::Match($envContent,$dbFormat)

$var = docker inspect --format='{{ .Config.Env}}' $dbServer
$passFormat = '(?<=sa_password=).*?(?=\s)'
$dbPass = [regex]::Match($var,$passFormat) 


$command = "C:\run\mvx\Scripts\Update-NAVTxtFromApplication2015.ps1 -Path C:\run\mvx\repo\NAV\ -Server $dbServer -Database $dbName -Password $dbPass"


$command += " -Verbose"
docker exec $navContainerName powershell -command $command

}
Export-ModuleMember Update-GitFromMvContainer