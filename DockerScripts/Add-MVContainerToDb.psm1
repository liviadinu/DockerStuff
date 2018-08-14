function Add-MvContainerToDb {

  Param(
  [Parameter(Mandatory=$true)]
  [string]$containerName,
  [Parameter(Mandatory=$true)]
  [string]$dbcontainername,
  [Parameter(Mandatory=$true)]
  [string]$licenseFile  = "",
  [string]$navImageNameTag = "",
  [string]$locale,
  [Parameter(Mandatory=$true)]
  [string]$gitFolder,
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

if ($navImageNameTag -eq "") {$navImageNameTag ='mvxregistry/mv-dynamics-nav:latest'}

$hostname = $containerName 
if ($locale -eq "") {$locale = "nl-NL"}

$sRawString = Get-Content "$PSScriptRoot\Setups.ini" | Out-String
$sStringToConvert = $sRawString -replace '\\', '\\'
$Settings = convertfrom-stringdata $sStringToConvert                                                   
$licenseFile = $Settings.licenseFile 

  $StopWatchDatabase = New-Object -TypeName System.Diagnostics.Stopwatch 
  $StopWatchDatabase.Start();
  $var = docker ps --format='{{.Names}}' -a --filter "name=$dbcontainername"
  if ($var -eq $dbcontainername) { docker rm $dbcontainername --force }
  Write-Host -ForegroundColor Yellow "Creating Database container $dbcontainername..."
  docker run -d --hostname=$dbcontainername --restart unless-stopped --memory 4G -e locale=$locale -e ACCEPT_EULA=Y -e sa_password=$password -v C:/temp/:C:/temp --name $dbcontainername $dbimage

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
$dbNamePattern = '(DATABASE) +\[(.*?)\]'
$logs = docker logs $dbcontainername
$dbname = [regex]::Match($logs,$dbNamePattern).Groups[2].Value 

docker logs $dbcontainername

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


$StopWatch.Stop();
Write-Host -ForegroundColor Green "Finished. Total time for setup:" $StopWatch.Elapsed.ToString()

}

Export-ModuleMember Add-MvContainerToDb
