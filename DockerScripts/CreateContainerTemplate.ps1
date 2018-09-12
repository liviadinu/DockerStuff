$hostname = 'test'
$gitFolder = "C:\ProgramData\NavContainerHelper\Extensions\Git\MVX"
$navImageNameTag = 'nav2017'
$licenseFile = "C:\Users\livia\Downloads\Updated_development_license\K3-5194146-31072018.flf"
$dbcred = get-credential
$dbname = 'Latvia2017'
$dbcontainername = 'test2-db'



$other = "--volume $($gitFolder):C:\run\mvx\repo --env locale=nl-NL -p 587:587"
New-NavContainer -containerName $hostname -accept_eula -accept_outdated -assignPremiumPlan -auth NavUserPassword -Credential $dbcred -databaseCredential $dbcred -databaseName $dbname -databaseServer $dbcontainername -doNotExportObjectsToText -FileSharePort 21 -imageName $navImageNameTag -includeCSide -licenseFile $licenseFile -restart unless-stopped -shortcuts Desktop -updateHosts