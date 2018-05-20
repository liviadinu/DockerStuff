function New-MvDevContainer {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [Parameter(Mandatory=$true)]
  [string]$dbcontainername,
  [Parameter(Mandatory=$true)]
  [string]$licenseFile,
  [string]$navImageNameTag = "",
  [string]$dbimage = "",
  [switch]$createNewDb,
  [switch]$updatePSModules,
  [switch]$skipAdditionalSetups, # Auto-Test Company
  [string]$gitFolder,
  [Int32]$uidOffset,
  [ValidateSet('LT','LV','BH')]
  [string]$countryCode=''  
  )
$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatch.Start();

if ($containerName -eq $dbcontainername) {Write-Error "Containers must be named differently. Restart the process and rename these parameters."
                                          Read-Host
										  exit   }

if($updatePSModules){
    Install-Module -Name navcontainerhelper
    Import-Module -Name navcontainerhelper -Force
}

$timeout = 1800
$securePassword = Read-Host -Prompt "Enter 'sa' password" -AsSecureString
$dbcred = New-Object System.Management.Automation.PSCredential("sa", $securePassword)
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

if ($navImageNameTag -eq "") {
    switch($countryCode )
    {
     ""   {$navImageNameTag ='mvxregistry/mv-dynamics-nav:latest'}
     "LT" {$navImageNameTag ='mvxregistry/mv-dynamics-nav:lt-latest'}
     "LV" {$navImageNameTag ='mvxregistry/mv-dynamics-nav:lv-latest'}
     "BH" {$navImageNameTag ='mvxregistry/mv-dynamics-nav:bh-latest'}
    }
 }

$hostname = $containerName 
if ($dbimage -eq "") {
    switch($countryCode ){
    ""  {$dbimage = 'mvxregistry/mvxsql:latest'}
    "LT"  {$dbimage = 'mvxregistry/mvxsql:lt.latest'}
    "LV"  {$dbimage = 'mvxregistry/mvxsql:lv.latest'}
    "BH"  {$dbimage = 'mvxregistry/mvxsql:bh.latest'}
    }
}


if($createNewDb) {
  $StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
  $StopWatchDatabase.Start();
  $var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"
  if ($var -eq $dbcontainername) { docker rm $dbcontainername --force }
  Write-Host -ForegroundColor Yellow "Creating Database container $dbcontainername..."
  docker run -d --hostname=$dbcontainername --restart unless-stopped -e locale=nl-NL -e ACCEPT_EULA=Y -e sa_password=$password -v C:/temp/:C:/temp --name $dbcontainername $dbimage

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
}

if(!$createNewDb) {
  $var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"
  if ($var -eq '') { Write-Error -Message "No such container: $dbcontainername!"
                     Read-Host
                     exit}
}

$dbNamePattern = '(DATABASE) +\[(.*?)\]'
$logs = docker logs $dbcontainername
$dbname = [regex]::Match($logs,$dbNamePattern).Groups[2].Value 

docker logs $dbcontainername

if($createNewDb){
$StopWatchDatabase.Stop();
Write-Host -ForegroundColor Green "Time to setup database:" $StopWatchDatabase.Elapsed.ToString()
}

$nav = docker ps --format='{{.Names}}' -a --filter "name=$hostname"

if($nav -eq $hostname){
  docker rm $hostname --force
  Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$hostname\" -Recurse -Force
}

$AddtionalParam = "--env locale=nl-NL --restart unless-stopped"
if($gitFolder -ne '') {$AddtionalParam += " --volume $($gitFolder):C:\Run\Repo"}

new-navcontainer -accept_eula -containername $hostname -imageName $navImageNameTag -auth NavUserPassword -includecside -updateHosts -licenseFile $licenseFile `
-doNotExportObjectsToText -Credential $dbcred -accept_outdated -databaseServer $dbcontainername -databaseName $dbname -databaseCredential $dbcred `
-AdditionalParameters @($AddtionalParam) 


if(!$skipAdditionalSetups){
    $StopWatchMV = New-Object -TypeName System.Diagnostics.Stopwatch 
    $StopWatchMV.Start();
    docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"

    docker exec $hostname powershell -command "C:\run\mvx\ChangeUidOffset.ps1 -UidOffSet $uidOffset -pass $password -DatabaseServer $dbcontainername -DatabaseName $dbname"
    $StopWatchMV.Stop();
    Write-Host -ForegroundColor Green "Time to setup addtional components:" $StopWatchMV.Elapsed.ToString()
}

$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember New-MvDevContainer
