function Sync-MVContainer {
Param(
  [Parameter(Mandatory=$true)]
  [string]$navContainerName)

docker exec $hostname powershell -command "c:\run\prompt.ps1 ; Sync-NAVTenant -Mode ForceSync -CommitPerTable -ServerInstance NAV -Force -Verbose"
	}
Export-ModuleMember Sync-MVContainer