#Requires -Version 5.0
$ErrorActionPreference = "Stop"

Write-Host "[Adding ABK Environment ...]" -Foreground Yellow

Import-Module "$env:Home\env\abk_aliases.psm1"
