function Add-MVContainerToDb {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [Parameter(Mandatory=$true)]
  [string]$dbcontainername,
  [ValidateSet('LT','LV','BH','UKR','GR','EE','LVPOS')]
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

$hostOsVersion = [environment]::OSVersion.Version.Build
if ($hostOsVersion -eq " 18362") 
  {
    $defaultImageTageName = 'navapps/mv-dynamics-nav-1903:'
    $isolation = "process"
  }
else
  {
    $defaultImageTageName = 'navapps/mv-dynamics-nav:'
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

$hostname = $containerName 
if ($locale -eq "") {$locale = "nl-NL"}

$sRawString = Get-Content "$PSScriptRoot\Setups.ini" | Out-String
$sStringToConvert = $sRawString -replace '\\', '\\'
$Settings = convertfrom-stringdata $sStringToConvert  

if($licenseFile -eq ""){$licenseFile = $Settings.licenseFile -replace '"', '' }                                                 
if ($countryCode -eq "")
  {$gitFolderCode = "MV"} 
else 
  { $gitFolderCode = $countryCode }
                                              
if ($gitFolder -eq "")
 {
   $gitFolder = $Settings.gitFolder -replace '\$', $gitFolderCode
 }


$StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchDatabase.Start();
$var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"

$dbNamePattern = '(DATABASE) +\[(.*?)\]'
$logs = docker logs $dbcontainername
$dbname = [regex]::Match($logs,$dbNamePattern).Groups[2].Value 

$hostname = $containerName 
docker logs $dbcontainername
$nav = docker ps --format='{{.Names}}' -a --filter "name=$hostname"

if($nav -eq $hostname){
  docker rm $hostname --force
  Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$hostname\" -Recurse -Force
}

$AddtionalParam = "--env locale=nl-NL --cpu-shares=512"
if($gitFolder -ne '') {$AddtionalParam += " --volume $($gitFolder):C:\Run\mvx\Repo"}

new-navcontainer -accept_eula -accept_outdated -updateHosts -includecside -FileSharePort 21 -containername $hostname -imageName $navImageNameTag -auth NavUserPassword -licenseFile $licenseFile `
-doNotExportObjectsToText -Credential $dbcred -databaseServer $dbcontainername -databaseName $dbname -databaseCredential $dbcred `
-AdditionalParameters @($AddtionalParam) 


$StopWatchMV = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatchMV.Start();
docker exec $hostname powershell -command "C:\run\mvx\AdditionalMvComponents.ps1"

$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember Add-MVContainerToDb
