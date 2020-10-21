#Requires -Version 5.0
$ErrorActionPreference = "Stop"

#Requires -Modules ".\winBin\Modules\abk-lib"
# Import-Module ".\winBin\Modules\abk-lib" -Force
$ABK_ENV_FILE="abk_env.ps1"

# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------
$EXPECTED_NUMBER_OF_PARAMETERS=0

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
function PrintUsageAndExitWithCode ($scriptName, $exitErrorCode) {
    Write-Host "->" $MyInvocation.MyCommand.Name ($scriptName, $exitErrorCode) -ForegroundColor Yellow
    Write-Host "   $scriptName will uninstall ABK Environment and deleting links in $HOME_BIN_DIR, $HOME_ENV_DIR"
    Write-Host "   Usage: $scriptName"
    Write-Host "     $scriptName --help           - display this info"
    Write-Host "<-" $MyInvocation.MyCommand.Name "($exitErrorCode)" -ForegroundColor Yellow
    exit $exitErrorCode
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green

Write-Host "args.Count =" $args.Count
Write-Host "HOME_BIN_DIR = $HOME_BIN_DIR"
Write-Host "HOME_ENV_DIR = $HOME_ENV_DIR"
Write-Host

if (IsParameterHelp $args.Count $args[0]) {
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $EXIT_CODE_SUCCESS
}

if (-not (IsCorrectNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $args.Count)) {
    Write-Host "ERROR: Incorrect number of parameters" -ForegroundColor Red
    Write-Host "Expected: $EXPECTED_NUMBER_OF_PARAMETERS" -ForegroundColor Red
    Write-Host "Actual:" $args.Count -ForegroundColor Red
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS
}

$CURRENT_DIR=$(Split-Path -Parent $PSCommandPath)
Write-Host "CURRENT_DIR = $CURRENT_DIR"

Write-Host "HOME_BIN_DIR = $HOME_BIN_DIR"
# check for installation bin directory
# if (DoesDirectoryExist $HOME_BIN_DIR) {
#     Write-Host "[Deleting $HOME_BIN_DIR junction ...]"
#     # New-Item -ItemType Junction -Path $HOME -Name $BIN_DIR -Value $CURRENT_DIR\$SH_BIN_DIR
# }

