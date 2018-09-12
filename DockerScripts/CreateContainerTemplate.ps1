$hostname =
$gitFolder = 
$navImageNameTag = 
$licenseFile = 
$dbcred = get-credential
$dbname = 
$dbcontainername = 

$other = "--volume $($gitFolder):C:\run\mvx\repo --env locale=nl-NL"
New-NavContainer -containerName $hostname -accept_eula -accept_outdated -assignPremiumPlan -auth NavUserPassword -Credential $dbcred -databaseCredential $dbcred -databaseName $dbname -databaseServer $dbcontainername -doNotExportObjectsToText -FileSharePort 21 -imageName $navImageNameTag -includeCSide -licenseFile $licenseFile -restart unless-stopped -shortcuts Desktop -updateHosts