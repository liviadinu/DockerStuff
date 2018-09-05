function Add-MVContainerToDb {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [Parameter(Mandatory=$true)]
  [string]$dbcontainername,
  [ValidateSet('LT','LV','BH','UKR','GR')]
  [string]$countryCode,
  [string]$licenseFile,
  [string]$navImageNameTag,
  [string]$locale,
  [string]$gitFolder
  )
$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatch.Start();

if ($containerName -eq $dbcontainername) {Write-Error "Containers must be named differently. Restart the process and rename these parameters."
                                          Read-Host
										  exit   }

$timeout = 1800
$securePassword = Read-Host -Prompt "Enter 'sa' password" -AsSecureString
$dbcred = New-Object System.Management.Automation.PSCredential("sa", $securePassword)
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

if ($navImageNameTag -eq "") {
  $navImageNameTag ='mvxregistry/mv-dynamics-nav:latest'
  switch($countryCode){
		"" { $navImageNameTag += '.2018' }
		"UKR" { $navImageNameTag += '.2018' }
		"GR" { $navImageNameTag += '.2018' }
		}
}

$hostname = $containerName 
if ($locale -eq "") {$locale = "nl-NL"}

$sRawString = Get-Content "$PSScriptRoot\Setups.ini" | Out-String
$sStringToConvert = $sRawString -replace '\\', '\\'
$Settings = convertfrom-stringdata $sStringToConvert  

if($licenseFile -eq ""){$licenseFile = $Settings.licenseFile -replace '"', '' }                                                 

$StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchDatabase.Start();
$var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"

$dbNamePattern = '(DATABASE) +\[(.*?)\]'
$logs = docker logs $dbcontainername
$dbname = [regex]::Match($logs,$dbNamePattern).Groups[2].Value 

$hostname = $containerName 
docker logs $dbcontainername
$hostname = $containerName 
$nav = docker ps --format='{{.Names}}' -a --filter "name=$hostname"

if($nav -eq $hostname){
  docker rm $hostname --force
  Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$hostname\" -Recurse -Force
}

$AddtionalParam = "--env locale=$locale --restart unless-stopped"
if($gitFolder -ne '') {$AddtionalParam += " --volume $($gitFolder):C:\Run\mvx\Repo"}

new-navcontainer -accept_eula -containername $hostname -imageName $navImageNameTag -auth NavUserPassword -includecside -updateHosts -licenseFile $licenseFile `
-doNotExportObjectsToText -enableSymbolLoading -Credential $dbcred -accept_outdated -databaseServer $dbcontainername -databaseName $dbname -databaseCredential $dbcred `
-AdditionalParameters @($AddtionalParam) 

docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"
docker exec $hostname powershell -command "C:\run\mvx\ChangeUidOffset.ps1 -UidOffSet $uidOffset -pass $password -DatabaseServer $dbcontainername -DatabaseName $dbname"

$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember Add-MVContainerToDb
