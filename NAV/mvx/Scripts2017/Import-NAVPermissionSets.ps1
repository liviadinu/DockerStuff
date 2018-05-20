<#
    .Synopsis
    Import .xml file with Permission Sets into NAV databse
    .DESCRIPTION
    Script loads Permission Sets from .xml file. Then, each Permission Set is first deleted from NAV Database (if it exists)
    and then replaced with the new one, as loaded from file.
    .EXAMPLE
    Import-NAVPermissionSets.ps1 -Path E:\git\NAV\Objects\Example.xml -NAVServerInstance DynamicsNAV100
#>

#Import-Module "C:\Program Files\Microsoft Dynamics NAV\100\Service\Microsoft.Dynamics.Nav.Management.psd1" #Get/NEw/Remove-NAVServerPermission /PermissionSet


param (
    #Path for permissions file. Must be .xml
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$path,
    #Server address
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$NavServerInstance

)


Begin {
   
    $argumentList = @()
    $argumentList += ($myInvocation.MyCommand.Definition, " ")
    $argumentList += ("-path", "`"$path`"")
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
 
   Import-Module "C:\Program Files\Microsoft Dynamics NAV\100\Service\Microsoft.Dynamics.Nav.Management.psd1"
    
}
Process {

    Measure-Command{
        [xml]$xml = Get-Content $path
        $PermissionSets = $xml.PermissionSets.PermissionSet 
        $count = $xml.PermissionSets.PermissionSet.Count
        $i = 0 
        foreach ($permissionSet in $PermissionSets)
          {
            $result = Get-NAVServerPermission -ServerInstance $NavServerInstance -PermissionSetId $permissionSet.RoleID
            if (!$result -eq '')
              { 
                Remove-NAVServerPermissionSet `
                  -PermissionSetId $permissionSet.RoleID `
                  -ServerInstance $NavServerInstance -Force
                  $i++
                Write-Progress -Status "Processing $i of $count" -Activity 'Cleaning Existing Permissions...' -PercentComplete ($i / $count*100) 
              }
            
          }
         $i = 0 
         $count = $xml.PermissionSets.PermissionSet.Permission.Count 

        foreach ($permissionSet in $PermissionSets)
        {
            
            $permissionSetID = $permissionSet.RoleID
            $permissionSetName = $permissionSet.RoleName

            $result = Get-NAVServerPermission -ServerInstance $NavServerInstance -PermissionSetId $permissionSetID
            if ($result -eq $null)
              {      
                New-NAVServerPermissionSet `
                    -PermissionSetId $permissionSetID `
                    -PermissionSetName $permissionSetName `
                    -ServerInstance $NavServerInstance `
                    -Force
              }
                foreach ($permission in $permissionSet.Permission)
                {
                    $ObjectId = $permission.ObjectId

                    New-NAVServerPermission `
                      -ObjectId $permission.ObjectId `
                      -ObjectType $permission.ObjectType `
                      -PermissionSetId $permissionSetID `
                      -ServerInstance $NavServerInstance `
                      -Delete $permission.DeletePermission `
                      -Execute $permission.ExecutePermission `
                      -Insert $permission.InsertPermission `
                      -Modify $permission.ModifyPermission `
                      -Read $permission.ReadPermission `
                      -SecurityFilter $permission.SecurityFilter
                 $i++
                 Write-Progress -Status "Processing $i of $count" -Activity 'Adding Permissions...' -PercentComplete ($i / $count*100) 
                }
   
        }
       } `
       | Format-Table -AutoSize 
}



End {

Write-Host "Completed. Press any key to continue ..." -ForegroundColor Green
Read-Host
}




    


