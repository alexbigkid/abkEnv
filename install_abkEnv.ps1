#Requires -Version 5.0
$ErrorActionPreference = "Stop"

# Requires -Modules ".\winBin\Modules\abk-lib"
Import-Module ".\winBin\Modules\abk-lib" -Verbose
$ABK_ENV_FILE="abk_env.ps1"

# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------
$EXPECTED_NUMBER_OF_PARAMETERS=0
$ERROR_CODE=$ERROR_CODE_SUCCESS

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
function PrintUsageAndExitWithCode ($scriptName, $exitErrorCode) {
    Write-Host "->" $MyInvocation.MyCommand.Name ($scriptName, $exitErrorCode) -ForegroundColor Yellow
    Write-Host "   $scriptName will install ABK Environment with links in $HOME_BIN_DIR, $HOME_ENV_DIR"
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

Write-Host "   [args.Count      =" $args.Count "]"
Write-Host "   [BIN_DIR         = $BIN_DIR]"
Write-Host "   [ENV_DIR         = $HOME_BIN_DIR]"
Write-Host "   [HOME_BIN_DIR    = $HOME_BIN_DIR]"
Write-Host "   [HOME_ENV_DIR    = $HOME_ENV_DIR]"
Write-Host "   [SH_BIN_DIR      = $SH_BIN_DIR]"
Write-Host "   [SH_ENV_DIR      = $SH_ENV_DIR]"
Write-Host "   [SH_PACKAGES_DIR = $SH_PACKAGES_DIR]"
Write-Host "   [HOME            = $HOME]"
Write-Host "   [env:Home        = $env:Home]"
Write-Host

# if logged in on a computer through a different user, the $env:Home is not the same as $HOME
# which will cause some problems. So the $env:Home needs to be set to $HOME
if ( $HOME -ne $env:Home ) {
    Write-Host "   [setting env:Home to $HOME]"
    $env:Home=$HOME
}

# Is parameter --help?
if (Confirm-ParameterIsHelp $args.Count $args[0]) {
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $EXIT_CODE_SUCCESS
}

# Is number of parameters ok
if (-not (Confirm-CorrectNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $args.Count)) {
    Write-Host "ERROR: Incorrect number of parameters" -ForegroundColor Red
    Write-Host "Expected: $EXPECTED_NUMBER_OF_PARAMETERS" -ForegroundColor Red
    Write-Host "Actual:" $args.Count -ForegroundColor Red
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS
}

# Figure out what directory this script is executed from
$CURRENT_DIR=$(Split-Path -Parent $PSCommandPath)
# Write-Host "CURRENT_DIR = $CURRENT_DIR"

# check for installation bin directory
if (-not (Confirm-DirectoryExist $HOME_BIN_DIR)) {
    Write-Host "[Creating $HOME_BIN_DIR junction to $CURRENT_DIR\$SH_BIN_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $BIN_DIR -Value $CURRENT_DIR\$SH_BIN_DIR
}

# check for installation env directory
if (-not (Confirm-DirectoryExist $HOME_ENV_DIR)) {
    Write-Host "[Creating $HOME_ENV_DIR junction to $CURRENT_DIR\$SH_ENV_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $ENV_DIR -Value $CURRENT_DIR\$SH_ENV_DIR
}

# create user powershell profile if it does not exist yet
if (-not (Confirm-FileExist $profile)) {
    "creating user profile: $profile"
    New-Item -Path $profile -ItemType "file" -Force
}

# add abk environment to the powershell profile
if (-not (Add-AbkEnvironmentSettings $profile "$HOME_ENV_DIR\$ABK_ENV_FILE")) {
    PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $ERROR_CODE_NEED_FILE_DOES_NOT_EXIST
}

refreshenv

Write-Host "<-" $MyInvocation.MyCommand.Name "($ERROR_CODE)" -ForeGroundColor Green
Write-Host ""
exit $ERROR_CODE
