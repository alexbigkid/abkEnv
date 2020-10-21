#Requires -Version 5.0
$ErrorActionPreference = "Stop"

Import-Module "$HOME\bin\Modules\abk-aliases"


Write-Host ""
Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green
Write-Host "   [Adding ABK Environment ...]" -Foreground Yellow

if ( $HOME -ne $env:Home ) {
    Write-Host "   [setting env:Home to $HOME]"
    $env:Home=$HOME
}


Write-Host "<-" $MyInvocation.MyCommand.Name "($ERROR_CODE)" -ForeGroundColor Green
Write-Host ""
exit $ERROR_CODE
