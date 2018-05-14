﻿param
(
    [switch]$silent
)

$serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\1*\Service").FullName
if (Test-Path "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1") {
    Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1" -wa SilentlyContinue
} else {
    Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.dll" -wa SilentlyContinue
}

$roleTailoredClientFolder = (Get-Item "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client").FullName
$NavIde = Join-Path $roleTailoredClientFolder "finsql.exe"
if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Ide.psm1") {
    Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Ide.psm1" -wa SilentlyContinue
}
if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1") {
    Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1" -wa SilentlyContinue
}
if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.psd1") {
    Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -wa SilentlyContinue
}
if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Model.Tools.psd1") {
    Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Model.Tools.psd1" -wa SilentlyContinue
}

cd $PSScriptRoot
if (!$silent) {
    Write-Host -ForegroundColor Green "Welcome to the NAV Container PowerShell prompt"
    Write-Host
}