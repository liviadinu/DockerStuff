function New-MVContainers {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [ValidateSet('LT','LV','BH','UKR','GR','EE','LVPOS')]
  [string]$countryCode,
  [string]$licenseFile,
  [string]$navImageNameTag = "",
  [string]$dbimage = "",
  [string]$gitFolder = "",
  [string]$dblocale = "nl-NL",
  [bool]$updateEcoPosFiles=0
  )
$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatch.Start();
$dbcontainername = $containerName + '-db'

if ($countryCode -eq "")
     {
	   $gitFolderCode = "MV"
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

$hostOsVersion = [environment]::OSVersion.Version.Build
if ($hostOsVersion -eq " 18362") 
  {
    $defaultImageTageName = 'navapps/mv-dynamics-nav-1903:latest'
    $isolation = "process"
  }
else
  {
    $defaultImageTageName = 'navapps/mv-dynamics-nav:latest'
    $isolation = "hyperv"
  }

if ($navImageNameTag -eq "") {
  $navImageNameTag = $defaultImageTageName
  switch($countryCode)
       {
		""   { $navImageNameTag += 'latest.bc.mv'}
		"UKR"{ $navImageNameTag = 'mv.bc.autumn2018'}
		"GR" { $navImageNameTag = 'mv.bc.autumn2018'}
		"BH" { $navImageNameTag = 'mv.bc.autumn2018'}	
		"LT" { $navImageNameTag += 'latest.2018.baltic'} 
        "EE" { $navImageNameTag += 'latest.2018.baltic'}	
	    "LV" { $navImageNameTag += 'latest.2018.baltic'}
        "LVPOS"	{ $navImageNameTag += 'latest.2017.baltic'}	
	   }
}

$hostname = $containerName 
if ($dbimage -eq "") {
    switch($countryCode){
    ""    {$dbimage = 'navapps/mvxsql:mv.latest'}
    "LT"  {$dbimage = 'navapps/mvxsql:lt.latest'}
    "LV"  {$dbimage = 'navapps/mvxsql:lv.latest'}
    "BH"  {$dbimage = 'navapps/mvxsql:bh.latest'}
	"GR"  {$dbimage = 'navapps/mvxsql:gr.latest'}
	"UKR" {$dbimage = 'navapps/mvxsql:ukr.latest'}
	"EE"  {$dbimage = 'navapps/mvxsql:ee.latest'}
	"LVPOS" {$dbimage = 'navapps/mvxsql:lvpos.latest'}
    }
   if ($hostOsVersion -eq "18362") 
    {$dbimage = $dbimage+'.1903'}   	
}

$StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchDatabase.Start();
$var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"
if ($var -eq $dbcontainername) { docker rm $dbcontainername --force }

Write-Host -ForegroundColor Yellow "Creating Database container $dbcontainername..."
   if ($hostOsVersion -eq "18362") 
   {
     docker run -d --hostname=$dbcontainername --isolation $isolation --restart no -e locale=$locale -e ACCEPT_EULA=Y -e sa_password=$password -v C:/temp/:C:/temp --name $dbcontainername $dbimage
   }
   else
   {
      docker run -d --hostname=$dbcontainername --isolation $isolation --memory 3G --cpu-shares=512 --restart no -e locale=$locale -e ACCEPT_EULA=Y -e sa_password=$password -v C:/temp/:C:/temp --name $dbcontainername $dbimage
   }
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

$AddtionalParam = "--env locale=nl-NL --cpu-shares=512 --env CustomNavSettings=EnableTaskScheduler=true"
if($gitFolder -ne '') {$AddtionalParam += " --volume $($gitFolder):C:\Run\mvx\Repo"}

new-navcontainer -accept_eula -accept_outdated -updateHosts -includecside -FileSharePort 21 -containername $hostname -imageName $navImageNameTag -auth NavUserPassword -licenseFile $licenseFile `
-doNotExportObjectsToText -Credential $dbcred -databaseServer $dbcontainername -databaseName $dbname -databaseCredential $dbcred `
-AdditionalParameters @($AddtionalParam) 

$StopWatchMV = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchMV.Start();
docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"
docker exec $hostname powershell -command "C:\run\mvx\ChangeUidOffset.ps1 -UidOffSet $uidOffset -pass $password -DatabaseServer $dbcontainername -DatabaseName $dbname"


$StopWatchMV.Stop();
Write-Host -ForegroundColor Green "Time to setup addtional components:" $StopWatchMV.Elapsed.ToString()

Write-Host "Update hosts file with database server IP"
$file = "$env:windir\System32\drivers\etc\hosts"
$dbcontainerip = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $dbcontainername
$data = foreach($line in Get-Content $file){
  if($line -match $dbcontainername)
  { }
  else
  {
    $line
  }
}
"$dbcontainerip $dbcontainername" | Add-Content -PassThru $data
$data | Set-Content $file -Force

$hostsContent = Get-Content $file 
if ($hostsContent -like $dbcontainername)
{$hostsContent | select-string -pattern $dbcontainername -nomatch | Out-File $file -Force }
"$dbcontainerip $dbcontainername" | Add-Content -PassThru $file	

 
$StopWatchMV = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchMV.Start();
docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"
docker exec $hostname powershell -command "C:\run\mvx\ChangeUidOffset.ps1 -UidOffSet $uidOffset -pass $password -DatabaseServer localhost -DatabaseName MVDEVBC"

if($updateEcoPosFiles)
{ 	$navContainerPath = Join-Path "C:\ProgramData\NavContainerHelper\Extensions" $hostname
    $navMyPath = Join-Path $navContainerPath "my\mvx\ECO"
    Copy-Item -Path $navMyPath  -Destination "C:\" -Recurse -Force
    Copy-Item -Path $navMyPath  -Destination "C:\temp" -Recurse -Force	}
else{
    $navContainerPath = Join-Path "C:\ProgramData\NavContainerHelper\Extensions" $hostname
    $navMyPath = Join-Path $navContainerPath "my\mvx\ECO"
	Remove-Item -Path $navMyPath -Recurse -Force
}

$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember New-MVContainers
