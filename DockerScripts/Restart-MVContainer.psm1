function Restart-MVContainer {
Param(
  [Parameter(Mandatory=$true)]
  [string]$navContainerName,
  [switch]$All,
  [switch]$MarkToDelete,
  [switch]$SkipDeleteCheck)

$envContent = docker inspect --format='{{ .Config.Env}}' $navContainerName
$dbsFormat = '(?<=databaseServer=).*?(?=\s)'
$dbServer = [regex]::Match($envContent,$dbsFormat)

$dbFormat ='(?<=databaseName=).*?(?=\s)'
$dbName = [regex]::Match($envContent,$dbFormat)

$var = docker inspect --format='{{ .Config.Env}}' $dbServer
$passFormat = '(?<=sa_password=).*?(?=\s)'
$dbPass = [regex]::Match($var,$passFormat) 
$version = '2017'
$tag = Get-NavContainerImageName -containerName $navContainerName
[bool]$val = $tag -like '*2018*'
if ($val) {$version = '2018'}

$command = "C:\run\mvx\Scripts$version\Update-NAVApplicationFromTxt.ps1 -Files C:\run\mvx\repo\NAV\ -Server $dbServer -Database $dbName -Password $dbPass -LogFolder C:\run\mvx\"

switch($true)
{
  $All {$command += " -All"}
  $MarkToDelete {$command += " -MarkToDelete"}
  $SkipDeleteCheck {$command += " -SkipDeleteCheck"}
}
$command += " -Verbose"
docker exec $navContainerName powershell -command $command

}
Export-ModuleMember Restart-MVContainer