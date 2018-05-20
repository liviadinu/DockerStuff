﻿<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
#>
param (
    #Object files from which to update. Should be complete set of objects
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$Files,
    #SQL Server address
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$Server,
    #SQL Database to update
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$Database,
	#SQL Database password
    [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
    [String]$Password,
    #If set, all objects will be updated and compiled instead just different
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [switch]$All,
    #If set, objects will be compiled after they are imported
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [switch]$Compile,
    #If set, objects, which should be deleted, will be marked #TODELETE in version list
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [switch]$MarkToDelete,
    #If set, script will not check for deleted objects
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [switch]$SkipDeleteCheck,
    #Logfile path used to write the log files for each imported file
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [String]$LogFolder,
    #Disable progress dialog
    [Parameter(ValueFromPipelinebyPropertyName = $true)]
    [switch]$NoProgress

)

Begin {
    function Invoke-PostImportCompilation
    {
        Param(
            $Object
        )
        if (($Object.Type -eq 1) -and ($Object.ID -gt 2000000004))
        {
            if ($Object.ID -eq 2000000006) {
                NVR_NAVScripts\Compile-NAVApplicationObjectMulti -Filter "Type=$($Object.Type);Id=$($Object.ID)" -Server $Server -Database $Database -Password $Password -NavIde (Get-NAVIde) -SynchronizeSchemaChanges No
            } else {
                NVR_NAVScripts\Compile-NAVApplicationObjectMulti -Filter "Type=$($Object.Type);Id=$($Object.ID)" -Server $Server -Database $Database -Password $Password -NavIde (Get-NAVIde) -SynchronizeSchemaChanges Force
            }
        }
        if ($Object.Type -eq 7) { #menusuite
            NVR_NAVScripts\Compile-NAVApplicationObjectMulti -Filter "Type=$($Object.Type);Id=$($Object.ID)" -Server $Server -Database $Database -Password $Password -NavIde (Get-NAVIde) -SynchronizeSchemaChanges Force
        }
    }

    if (!($env:PSModulePath -like "*;$PSScriptRoot*")) 
    {
        $env:PSModulePath = $env:PSModulePath + ";$PSScriptRoot"
    }
    Import-Module -Name NVR_NAVScripts -DisableNameChecking
    Import-NAVModelTool
}    
Process{
    if ($NavIde -eq '') 
    {
        $NavIde = Get-NAVIde
    }
    $FileObjects = Get-NAVApplicationObjectProperty -Source $Files
    $FileObjectsHash = $null
    $FileObjectsHash = @{}
    $i = 0
    $count = $FileObjects.Count
    $UpdatedObjects = New-Object -TypeName System.Collections.ArrayList
    $StartTime = Get-Date

    foreach ($FileObject in $FileObjects)
    {
        if (!$FileObject.Id) 
        {
            Continue
        }
        $i++
        $NowTime = Get-Date
        $TimeSpan = New-TimeSpan $StartTime $NowTime
        $percent = $i / $count
        if ($percent -gt 1) 
        {
            $percent = 1
        }
        $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

        if (($i % 10) -eq 0) 
        {
            if (-not $NoProgress) 
            {
                Write-Progress -Status "Processing $i of $count" -Activity 'Comparing objects...' -PercentComplete ($percent*100) -SecondsRemaining $remtime
            }
        }
        $Type = Get-NAVObjectTypeIdFromName -TypeName $FileObject.ObjectType
        $Id = $FileObject.Id
        $FileObjectsHash.Add("$Type-$Id",$true)
        $NAVObject = Get-SQLCommandResult -Server $Server -Database $Database -Password $Password -Command "select [Type],[ID],[Version List],[Modified],[Name],[Date],[Time] from Object where [Type]=$Type and [ID]=$Id"
        #$NAVObject = $NAVObjects | ? (($_.Type -eq $Type) -and ($_.Id -eq $FileObject.Id))
        if (($FileObject.Modified -eq $NAVObject.Modified) -and
            ($FileObject.VersionList -eq $NAVObject.'Version List') -and
            ($FileObject.Time.TrimStart(' ') -eq $NAVObject.Time.ToString('HH:mm:ss')) -and
            ($FileObject.Date -eq $NAVObject.Date.ToString('dd-MM-yy')) -and
            (!$All)
        )
        {
            Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) skipped..."
        }
        else 
        {
            $ObjToImport = @{
                'Type'   = $Type
                'ID'     = $Id
                'FileName' = $FileObject
            }
            if ($Id -gt 0) 
            {
                $UpdatedObjects += $ObjToImport
                if ($All) 
                {
                    Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) forced..."
                }
                else 
                {
                    if (($NAVObject -eq $null) -or ($NAVObject -eq '')) 
                    {
                        Write-Host -Object "$($FileObject.ObjectType) $($FileObject.Id) is new..."
                    }
                    else
                    {
                        Write-Host -Object "$($FileObject.ObjectType) $($FileObject.Id) differs: Modified=$($FileObject.Modified -eq $NAVObject.Modified) Version=$($FileObject.VersionList -eq $NAVObject.'Version List') Time=$($FileObject.Time.TrimStart(' ') -eq $NAVObject.Time.ToString('HH:mm:ss')) $FileObject.Date $NAVObject.Date.ToString('dd-MM-yy')"
                    }
                }
            }
        }
    }

    $i = 0
    $count = $UpdatedObjects.Count
    if (!$SkipDeleteCheck) 
    {
        $NAVObjects = Get-SQLCommandResult -Server $Server -Database $Database -Password $Password -Command 'select [Type],[ID],[Version List],[Modified],[Name],[Date],[Time] from Object where [Type]>0'
        $i = 0
        $count = $NAVObjects.Count
        $StartTime = Get-Date

        foreach ($NAVObject in $NAVObjects)
        {
            if (!$NAVObject.ID) 
            {
                Continue
            }

            $i++
            $NowTime = Get-Date
            $TimeSpan = New-TimeSpan $StartTime $NowTime
            $percent = $i / $count
            $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

            if (-not $NoProgress) 
            {
                Write-Progress -Status "Processing $i of $count" -Activity 'Checking deleted objects...' -PercentComplete ($i / $count*100) -SecondsRemaining $remtime
            }
            $Type = Get-NAVObjectTypeNameFromId -TypeId $NAVObject.Type
            #$FileObject = $FileObjects | Where-Object {($_.ObjectType -eq $Type) -and ($_.Id -eq $NAVObject.ID)}
            $Exists = $FileObjectsHash["$($NAVObject.Type)-$($NAVObject.ID)"]
            if (!$Exists) 
            {
                Write-Warning -Message "$Type $($NAVObject.ID) Should be removed from the database!"
                if ($MarkToDelete) 
                {
                    $Result = Get-SQLCommandResult -Server $Server -Database $Database -Password $Password -Command "update Object set [Version List] = '#DELETE', [Name]='#DELETED $($NAVObject.Type):$($NAVObject.ID)' where [Type]=$($NAVObject.Type) and [ID]=$($NAVObject.ID)"
                }
            }
        }
    }
    
    $i = 0
    $count = $UpdatedObjects.Count
        
    $StartTime = Get-Date
    foreach ($ObjToImport in $UpdatedObjects) 
    {
        $i++
        $NowTime = Get-Date
        $TimeSpan = New-TimeSpan $StartTime $NowTime
        $percent = $i / $count
        if ($percent -gt 1) 
        {
            $percent = 1
        }
        $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

        if (-not $NoProgress) 
        {
            Write-Progress -Status "Importing $i of $count" -Activity 'Importing objects...' -CurrentOperation $ObjToImport.FileName.FileName -PercentComplete ($percent*100) -SecondsRemaining $remtime
        }
        if (($ObjToImport.Type -eq 7) -and ($ObjToImport.Id -lt 1050))
        {
            Write-Host -Object "Menusuite with ID < 1050 skipped... (Id=$($ObjToImport.Id))"
        } else 
        {
            Import-NAVApplicationObjectFiles -files $ObjToImport.FileName.FileName -Server $Server -Database $Database -Password $Password -NavIde (Get-NAVIde) -LogFolder $LogFolder 
        }
        Invoke-PostImportCompilation -Object $ObjectToImport
    }

    Write-Host -Object ''
    Write-Host -Object "Updated $($UpdatedObjects.Count) objects..."

    if ($Compile) 
    {
        $i = 0
        $count = $UpdatedObjects.Count
        $StartTime = Get-Date

        foreach ($UpdatedObject in $UpdatedObjects)
        {
            $i++
            $NowTime = Get-Date
            $TimeSpan = New-TimeSpan $StartTime $NowTime
            $percent = $i / $count
            $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

            if (-not $NoProgress) 
            {
                Write-Progress -Status "Processing $i of $count" -Activity 'Compiling objects...' -PercentComplete ($i / $count*100) -SecondsRemaining $remtime
            }

            NVR_NAVScripts\Compile-NAVApplicationObject -Filter "Type=$($UpdatedObject.Type);Id=$($UpdatedObject.ID)" -Server $Server -Database $Database -Password $Password -NavIde (Get-NAVIde) -LogFolder $LogFolder
        }
        Write-Host -Object "Compiled $($UpdatedObjects.Count) objects..."
    }

}
End {
}