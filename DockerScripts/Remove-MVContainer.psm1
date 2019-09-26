function Remove-MVContainer {
Param(
  [Parameter(Mandatory=$true)]
  [string]$navContainerName)


$envContent = docker inspect --format='{{ .Config.Env}}' $navContainerName
$dbsFormat = '(?<=databaseServer=).*?(?=\s)'
$dbServer = [regex]::Match($envContent,$dbsFormat)
docker rm $dbServer -f
Remove-NavContainer -containerName $navContainerName

}
Export-ModuleMember Remove-MVContainer