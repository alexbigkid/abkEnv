#Requires -Version 5.0
$ErrorActionPreference = "Stop"

$ABK_FUNCTION_LIB_FILE=".\winBin\abk_lib.psm1"
Import-Module $ABK_FUNCTION_LIB_FILE -Force
$ABK_ENV_FILE="abk_env.ps1"

#---------------------------
# variables definitions
#---------------------------
$TRACE = $true
$REFRESH = $false
$EXPECTED_NUMBER_OF_PARAMETERS=0

# directory definitions
$BIN_DIR="bin"
$ENV_DIR="env"
$HOME_BIN_DIR="$HOME\$BIN_DIR"
$HOME_ENV_DIR="$HOME\$ENV_DIR"
$SH_BIN_DIR="winBin"
$SH_ENV_DIR="winEnv"
$SH_PACKAGES_DIR="winPackages"
$SH_DIR=""


#---------------------------
# functions
#---------------------------
function PrintUsageAndExitWithCode ($scriptName, $exitErrorCode) {
    Write-Host "->" $MyInvocation.MyCommand.Name ($scriptName, $exitErrorCode) -ForegroundColor Yellow
    Write-Host "   $scriptName will create or refresh all links in $HOME_BIN_DIR, $HOME_ENV_DIR and choco packages"
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

if( $TRACE -eq $true ) {
    Write-Host "ABK_FUNCTION_LIB_FILE = $ABK_FUNCTION_LIB_FILE"
    Write-Host "args.Count =" $args.Count
    Write-Host "HOME_BIN_DIR = $HOME_BIN_DIR"
    Write-Host "HOME_ENV_DIR = $HOME_ENV_DIR"
    Write-Host "SH_DIR  = $SH_DIR"
    Write-Host
}

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
# Write-Host "CURRENT_DIR = $CURRENT_DIR"

# check for installation bin directory
if (-not (DoesDirectoryExist $HOME_BIN_DIR)) {
    Write-Host "[Creating $HOME_BIN_DIR junction to $CURRENT_DIR\$SH_BIN_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $BIN_DIR -Value $CURRENT_DIR\$SH_BIN_DIR
}

# check for installation env directory
if (-not (DoesDirectoryExist $HOME_ENV_DIR)) {
    Write-Host "[Creating $HOME_ENV_DIR junction to $CURRENT_DIR\$SH_ENV_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $ENV_DIR -Value $CURRENT_DIR\$SH_ENV_DIR
}

AddToPathVariable($HOME_BIN_DIR)

if (-not (DoesFileExist $profile)) {
    "creating user profile: $profile"
    New-Item -Path $profile -ItemType "file" -Force
}

if (-not (AddAbkEnvironmentSettings $profile "$HOME_ENV_DIR\$ABK_ENV_FILE")) {
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $ERROR_CODE_NEED_FILE_DOES_NOT_EXIST
}

Write-Host "<-" $MyInvocation.MyCommand.Name "($ERROR_CODE)" -ForeGroundColor Green
Write-Host ""
exit $ERROR_CODE
