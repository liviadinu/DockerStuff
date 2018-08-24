param([Int32]$UidOffSet,[String]$pass,[String]$DatabaseServer,[String]$DatabaseName)

[int] $CommandTimeout=30

$SQLCommand = "UPDATE [$('$ndo$dbproperty')] SET [uidoffset] = $UidOffSet"
       
if (!([string]::IsNullOrEmpty($ServerInstanceObject.DatabaseInstance))){
    $DatabaseServer = "$($DatabaseServer)\$($ServerInstanceObject.DatabaseInstance)"
}
$connectionString = "Data Source=$DatabaseServer; User ID=sa; Password=$pass;Initial Catalog=$DatabaseName"

if ($ShowWriteHost){
    write-Host -ForegroundColor Green "Invoke-SQL with this statement on database '$($ServerInstanceObject.DatabaseName)':"
    Write-Host -ForegroundColor Gray $SQLCommand
}

$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
$connection.Open()
$command.CommandTimeout = $CommandTimeout
$adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataSet) | Out-Null

$connection.Close()
$connection.Dispose()


