#Requires -Version 5.0
$ErrorActionPreference = "Stop"

$ABK_BIN_DIR="$HOME\abkBin"

Import-Module "$ABK_BIN_DIR\Modules\abk-lib"
Import-Module "$ABK_BIN_DIR\Modules\abk-aliases"
$EXIT_CODE=$ERROR_CODE_SUCCESS

# Write-Host ""
# Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green
Write-Host "   [Adding ABK Environment ...]" -Foreground Yellow

if ( $HOME -ne $env:Home ) {
    Write-Host "   [setting env:Home to $HOME]"
    $env:Home=$HOME
}

$env:PSModulePath = Add-PathToEnvVariable $env:PSModulePath "$ABK_BIN_DIR\Modules"
$env:Path = Add-PathToEnvVariable $env:Path $ABK_BIN_DIR

# Write-Host "<-" $MyInvocation.MyCommand.Name "($ERROR_CODE)" -ForeGroundColor Green
# Write-Host ""
exit $EXIT_CODE
