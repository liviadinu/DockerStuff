<#
    .Synopsis
    Export .xml file with Permission Sets from NAV databse
    .DESCRIPTION
    Script exports Permission Sets into .xml file on a specified path
    .EXAMPLE
    Export-NAVPermissionSets.ps1 -Path E:\git\NAV\Objects\Example.xml -PermissionSet *EXAMPLE -NAVServerInstance DynamicsNAV100
#>


#Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" #Export NAV App Permission Set


param (
    #Path for permissions file. 
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$Path,

    [Parameter(Mandatory = $false,ValueFromPipelinebyPropertyName = $true)]
    [String]$FileName,
     #Name of permissions set. 
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$PermissionSet,

    #Server address
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$NavServerInstance

)

Begin {
  Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" #Export NAV App Permission Set
  if($FileName -eq '')
  {
    $FileName = 'MVPermissionSet'
  }
    $argumentList = @()
    $argumentList += ($myInvocation.MyCommand.Definition, " ")
    $argumentList += ("-Path", "`"$path`"")
    $argumentList += ("-FileName", "`"$FileName`"")
    $argumentList += ("-PermissionSet", "`"$PermissionSet`"")
    $argumentList += ("-NavServerInstance", "`"$NavServerInstance`"")
    Write-Host $argumentList
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
    # Check to see if we are currently running "as Administrator"
    if (!$myWindowsPrincipal.IsInRole($adminRole))
     {
       # We are not running "as Administrator" - so relaunch as administrator
   
       # Create a new process object that starts PowerShell
       $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
       # Specify the current script path and name as a parameter
       $newProcess.Arguments =  $argumentList;
   
   
       # Indicate that the process should be elevated
       $newProcess.Verb = "runas";
   
       # Start the new process
       [System.Diagnostics.Process]::Start($newProcess);
   
       # Exit from the current, unelevated, process
       exit
       }
}

Process{
$FilePath = $Path + $FileName + '.xml'
Export-NAVAppPermissionSet -Path $FilePath -PermissionSetId $PermissionSet -ServerInstance $NavServerInstance -Force
}

End
{
 Write-Host "Completed." -ForegroundColor Green
}