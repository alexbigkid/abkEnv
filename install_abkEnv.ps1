#Requires -Version 5.0
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

# file definitions
$ABK_FUNCTION_LIB_FILE=".\winBin\abk_lib.ps1"
$NEW_BASH_PROFILE="ps_profile.ps1"
$ORG_BASH_PROFILE=$profile
$ABK_BASH_PROFILE="ps_abk.ps1"


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




# CreateNewBashProfile ()
# {
#     if [ -f $HOME/$ORG_BASH_PROFILE ]; then
#         echo "[moving $HOME/$ORG_BASH_PROFILE to $HOME_ENV_DIR/$ORG_BASH_PROFILE]"
#         mv $HOME/$ORG_BASH_PROFILE $HOME_ENV_DIR/$ORG_BASH_PROFILE
#         cat > $1 << EOF_NEW_BASH_PROFILE_IF
# # the original .bash_profile is MOVED to \$HOME/env/$ORG_BASH_PROFILE
# # in order to completely remove abk environment and restore the
# # previous bash settings, please execute \$HOME/bin/uninstall_abkEnv.sh

# #-------------------------
# # setting previous environment
# #-------------------------
# if [ -f \$HOME/env/$ORG_BASH_PROFILE ]; then
#   source \$HOME/env/$ORG_BASH_PROFILE
# fi

# EOF_NEW_BASH_PROFILE_IF
#     else
#         echo "[no original $HOME/$ORG_BASH_PROFILE found]"
#         cat > $1 << EOF_NEW_BASH_PROFILE_ELSE
# # there was no original .bash_profile so it was not MOVED to \$HOME/env/$ORG_BASH_PROFILE
# # in order to completely remove abk environment and restore the
# # previous bash settings, please execute \$HOME/bin/uninstall_abkEnv.sh

# EOF_NEW_BASH_PROFILE_ELSE
#     fi

#     cat >> $1 << EOF_NEW_BASH_PROFILE_COMMON
# #-------------------------
# # setting up abk environment
# #-------------------------
# if [ -f \$HOME/env/$ABK_BASH_PROFILE ]; then
#   source \$HOME/env/$ABK_BASH_PROFILE
# fi

# EOF_NEW_BASH_PROFILE_COMMON

#     CreateLink $SH_ENV_DIR/$NEW_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
# }

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green

if ( Test-Path $ABK_FUNCTION_LIB_FILE -PathType Leaf ) {
    . $ABK_FUNCTION_LIB_FILE
}
else {
    Write-Host "ERROR: " -ForeGroundColor Red -NoNewLine
    Write-Host "$ABK_FUNCTION_LIB_FILE does not exist in the local directory."
    Write-Host "  $ABK_FUNCTION_LIB_FILE contains common definitions and functions"
    Write-Host "  $ABK_FUNCTION_LIB_FILE All binaries and shell scripts will be located in ~/bin"
    exit 1
}

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
if (-not (DoesDirectoryExist($HOME_BIN_DIR))) {
    Write-Host "[Creating $HOME_BIN_DIR junction to $CURRENT_DIR\$SH_BIN_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $BIN_DIR -Value $CURRENT_DIR\$SH_BIN_DIR
}

# check for installation env directory
if (-not (DoesDirectoryExist($HOME_ENV_DIR))) {
    Write-Host "[Creating $HOME_ENV_DIR junction to $CURRENT_DIR\$SH_ENV_DIR ...]"
    New-Item -ItemType Junction -Path $HOME -Name $ENV_DIR -Value $CURRENT_DIR\$SH_ENV_DIR
}

# check whether the scripts already installed or need to be refreshed
# $CURRENT_FILE=$MyInvocation.MyCommand.Name
# $BIN_INSTALL_FILE="$HOME_BIN_DIR\$CURRENT_FILE"
# Write-Host "BIN_INSTALL_FILE = $BIN_INSTALL_FILE"
# if (DoesFileExist($BIN_INSTALL_FILE)) {
#     if (IsFileALink($BIN_INSTALL_FILE)) {
#         $REFRESH=$true
#     } else {
#         PrintUsageAndExitWithCode $MyInvocation.MyCommand.Name $ERROR_CODE_IS_INSTALLED_BUT_NO_LINK
#     }
# }

# Write-Host
# Write-Host "[deleting broken links in $HOME_BIN_DIR ...]"
# RemoveBrokenLinksFromDirectory( $HOME_BIN_DIR )
# # find -L $HOME_BIN_DIR -type l -exec rm -- {} +
# Write-Host "[deleting broken links in $HOME_ENV_DIR ...]"
# RemoveBrokenLinksFromDirectory( $HOME_ENV_DIR )
# find -L $HOME_ENV_DIR -type l -exec rm -- {} +

# set script directory
# Write-Host
# if ( $REFRESH -eq $false ) {
#     $SH_DIR = GetAbsolutePath( $MyInvocation.MyCommand.Name )
#     Write-Host "[creating links ...]"
# } else {
#     $SH_DIR = GetPathFromLink( $MyInvocation.MyCommand.Name )
#     Write-Host "[refreshing links ...]"
# }
# $SH_BIN_DIR = $SH_DIR/$SH_BIN_DIR
# $SH_ENV_DIR = $SH_DIR/$SH_ENV_DIR

# if ( $TRACE -eq $true ) {
#     Write-Host "REFRESH    = $REFRESH"
#     Write-Host "SH_DIR     = $SH_DIR"
#     Write-Host "SH_BIN_DIR = $SH_BIN_DIR"
#     Write-Host "SH_ENV_DIR = $SH_ENV_DIR"
# }

# # if installing, not refreshing
# if [ $REFRESH == 0 ]; then
#     CreateNewBashProfile $SH_ENV_DIR/$NEW_BASH_PROFILE
# fi

# # create/update links in project dir
# echo ""
# echo "[links in $HOME_BIN_DIR to $SH_DIR ...]"
# FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
# for FILE in ${FILES}
# do
#     CreateLink $FILE $HOME_BIN_DIR/$(basename $FILE)
# done

# # create/update links to macBin
# echo ""
# echo "[links in $HOME_BIN_DIR to $SH_BIN_DIR ...]"
# FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
# for FILE in ${FILES}
# do
#     CreateLink $FILE $HOME_BIN_DIR/$(basename $FILE)
# done

# # create/update links to macEnv
# echo ""
# echo "[links in $HOME_ENV_DIR to $SH_ENV_DIR ...]"
# FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.env' -o -name '*.m4a' -o -name '*.mp3')
# for FILE in ${FILES}
# do
#     CreateLink $FILE $HOME_ENV_DIR/$(basename $FILE)
# done

Write-Host "<-" $MyInvocation.MyCommand.Name -ForeGroundColor Green
Write-Host ""
exit $ERROR_CODE
