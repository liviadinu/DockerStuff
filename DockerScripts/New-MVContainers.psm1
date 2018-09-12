function New-MVContainers {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [ValidateSet('LT','LV','BH','UKR','GR')]
  [string]$countryCode,
  [string]$licenseFile,
  [string]$navImageNameTag = "",
  [string]$dbimage = "",
  [string]$gitFolder,
  [string]$dblocale  
  )
$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatch.Start();
$dbcontainername = $containerName + '-db'

if ($countryCode -eq "")
     {
	   $gitFolderCode = "MVX"
	 } 
else { 
       $gitFolderCode = $countryCode 
     }

$sRawString = Get-Content "$PSScriptRoot\Setups.ini" | Out-String
$sStringToConvert = $sRawString -replace '\\', '\\'
$Settings = convertfrom-stringdata $sStringToConvert                                                   
if ($gitFolder -eq "")
 {
   $gitFolder = $Settings.gitFolder -replace '\$', $gitFolderCode
 }
$uidOffset = $Settings.uidOffset
if($licenseFile -eq ""){$licenseFile = $Settings.licenseFile -replace '"', '' } 

$timeout = 2800
$securePassword = Read-Host -Prompt "Enter 'sa' password" -AsSecureString
$dbcred = New-Object System.Management.Automation.PSCredential("sa", $securePassword)
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

if ($navImageNameTag -eq "") {
  $navImageNameTag ='mvxregistry/mv-dynamics-nav:latest'
  switch($countryCode)
       {
		""   { $navImageNameTag += '.2018'}
		"UKR"{ $navImageNameTag += '.2018'}
		"GR" { $navImageNameTag += '.2018'}
	    "LV" { $navImageNameTag += '.2017cu11'}     
		"BH" { $navImageNameTag += '.2017cu11'}		
	   }
}

$hostname = $containerName 
if ($dbimage -eq "") {
    switch($countryCode){
    ""    {$dbimage = 'mvxregistry/mvxsql:mv.latest'}
    "LT"  {$dbimage = 'mvxregistry/mvxsql:lt.latest'}
    "LV"  {$dbimage = 'mvxregistry/mvxsql:lv.latest'}
    "BH"  {$dbimage = 'mvxregistry/mvxsql:bh.latest'}
	"GR"  {$dbimage = 'mvxregistry/mvxsql:gr.latest'}
	"UKR" {$dbimage = 'mvxregistry/mvxsql:ukr.latest'}
    }
}

$StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchDatabase.Start();
$var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"
if ($var -eq $dbcontainername) { docker rm $dbcontainername --force }
Write-Host -ForegroundColor Yellow "Creating Database container $dbcontainername..."
docker run -d --hostname=$dbcontainername --memory 3G -e locale=$locale -e ACCEPT_EULA=Y -e sa_password=$password -v C:/temp/:C:/temp --name $dbcontainername $dbimage

$prevLog = ""
Write-Host -ForegroundColor Yellow "Waiting for container $dbcontainername to be ready"
$cnt = $timeout
$log = ""
do {
  Start-Sleep -Seconds 1
  $logs = docker logs $dbcontainername
  if ($logs) { $log = [string]::Join("`r`n",$logs) }
  $newLog = $log.subString($prevLog.Length)
  $prevLog = $log
  if ($newLog -ne "") {
			$cnt = $timeout
			Write-Host -NoNewline $newLog 
			}
  if ($cnt-- -eq 0 -or $log.Contains("Msg")) { 
			Write-Host "Error"
			Write-Host $log
			throw "Initialization of container $containerName failed"
			Read-Host
			exit
		}
  } while (!($log.Contains("VERBOSE: Started SQL Server.")))
	Write-Host  


$dbNamePattern = '(DATABASE) +\[(.*?)\]'
$logs = docker logs $dbcontainername
$dbname = [regex]::Match($logs,$dbNamePattern).Groups[2].Value 

docker logs $dbcontainername
$StopWatchDatabase.Stop();
Write-Host -ForegroundColor Green "Time to setup database:" $StopWatchDatabase.Elapsed.ToString()

$nav = docker ps --format='{{.Names}}' -a --filter "name=$containerName"
if($nav -eq $containerName){
  docker rm $containerName --force
    Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$hostname\" -Recurse -Force
}

$AddtionalParam = "--env locale=nl-NL"
if($gitFolder -ne '') {$AddtionalParam += " --volume $($gitFolder):C:\Run\mvx\Repo"}

new-navcontainer -accept_eula -accept_outdated -updateHosts -includecside -FileSharePort 21 -containername $hostname -imageName $navImageNameTag -auth NavUserPassword -licenseFile $licenseFile `
-doNotExportObjectsToText -enableSymbolLoading -Credential $dbcred -databaseServer $dbcontainername -databaseName $dbname -databaseCredential $dbcred `
-AdditionalParameters @($AddtionalParam) 

$StopWatchMV = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchMV.Start();
docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"
docker exec $hostname powershell -command "C:\run\mvx\ChangeUidOffset.ps1 -UidOffSet $uidOffset -pass $password -DatabaseServer $dbcontainername -DatabaseName $dbname"

$StopWatchMV.Stop();
Write-Host -ForegroundColor Green "Time to setup addtional components:" $StopWatchMV.Elapsed.ToString()

$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember New-MVContainers
