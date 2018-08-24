Get-Item $PSScriptRoot  | Get-ChildItem -Recurse -file -Filter '*.ps1' |  Sort Name | foreach {

    Write-Verbose "Loading $($_.Name)"

    . $_.fullname
}

function Get-NAVIde
{
    if (!$env:NAVIdePath) 
    {
        return 'c:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\finsql.exe'
    }
    return (Join-Path -Path $env:NAVIdePath -ChildPath 'finsql.exe')
}

function Get-NAVIdePath
{
    if (!$env:NAVIdePath) 
    {
        return 'c:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client'
    }
    return $env:NAVIdePath
}

function Get-NAVAdminPath
{
    if (!$env:NAVServicePath) 
    {
        return 'c:\Program Files\Microsoft Dynamics NAV\100\Service'
    }
    return $env:NAVServicePath
}

function Get-NAVAdminModuleName
{
    #    return (Join-Path -Path (Get-NAVAdminPath) -ChildPath 'Microsoft.Dynamics.Nav.Management.dll')
    return (Join-Path -Path (Get-NAVAdminPath) -ChildPath 'Microsoft.Dynamics.Nav.Management.psd1')
}
function Import-NAVAdminTool
{
    [CmdletBinding()]
    param (
        [Switch]$Force
    )
    $module = Get-Module -Name 'Microsoft.Dynamics.Nav.Management'
    $modulepath = Get-NAVAdminModuleName
    if ($Force) 
    {
        Write-Host -Object "Removing module $($module.Path)"
        Remove-Module -Name 'Microsoft.Dynamics.Nav.Management' -Force
    }
    if (!($module) -or ($module.Path -ne $modulepath) -or ($Force)) 
    {
        if (!(Test-Path -Path $modulepath)) 
        {
            Write-Error -Message "Module $moduelpath not found!"
            return
        }
        Write-Host -Object "Importing NAVAdminTool from $modulepath"
        Import-Module "$modulepath" -DisableNameChecking -Force
        #& $modulepath #| Out-Null
        Write-Verbose -Message 'NAV admin tool imported'
    } else 
    {
        Write-Verbose -Message 'NAV admin tool already imported'
    }
}

function Import-NAVAppTools
{
    $modulepath = (Join-Path -Path (Get-NAVIdePath) -ChildPath 'Microsoft.Dynamics.Nav.Apps.Tools.psd1')
    $module = Get-Module -Name 'Microsoft.Dynamics.Nav.Apps.Tools'
    if (!($module) -or ($module.Path -ne $modulepath)) 
    {
        if (!(Test-Path -Path $modulepath)) 
        {
            Write-Error -Message "Module $moduelpath not found!"
            return
        }
        Write-Host -Object "Importing NAVModelTool from $modulepath"
        Import-Module -Global "$modulepath" -ArgumentList (Get-NAVIde) -DisableNameChecking -Force #-WarningAction SilentlyContinue | Out-Null
        Write-Verbose -Message 'NAV model tool imported'
    } else 
    {
        Write-Verbose -Message 'NAV model tool already imported'
    }
}


Export-ModuleMember -Function *
