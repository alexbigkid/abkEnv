#!/bin/bash

#---------------------------
# configurable variables definitions
#---------------------------
EXPECTED_NUMBER_OF_PARAMS=3
SWITCH_PARAMETER=$1
USER_NAME=$2
SSH_DOMAIN=$3
SSH_DIR="$HOME/.ssh"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
SSH_PRIVATE_KEY_NAME="$USER_NAME-$SSH_DOMAIN"
SSH_PUBLIC_KEY_NAME="$SSH_PRIVATE_KEY_NAME.pub"
PLIST_SERVICE_NAME="com.$SSH_DOMAIN.ssh-add.$SSH_PRIVATE_KEY_NAME"
BEGIN_OF_CONFIG_SECTION="# BEGIN_SSH_SECTION"
END___OF_CONFIG_SECTION="# END___SSH_SECTION"


#---------------------------
# variables definitions
#---------------------------
declare -r TRUE=0
declare -r FALSE=1

#---------------------------
# color variable definitions
#---------------------------
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color


#---------------------------
# exit error codes
#---------------------------
EXIT_CODE_SUCCESS=0
EXIT_CODE_GENERAL_ERROR=1
EXIT_CODE_NOT_BASH_SHELL=2
EXIT_CODE_REQUIRED_TOOL_IS_NOT_INSTALLED=3
EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS=4
EXIT_CODE_NOT_VALID_PARAMETER=5
EXIT_CODE_FILE_DOES_NOT_EXIST=6
EXIT_CODE_NOT_VALID_AWS_ACCOUNT_NUMBER=7
EXIT_CODE_FILE_IS_NOT_JSON_FILE=8
EXIT_CODE_FILE_IS_NOT_YAML_FILE=9
EXIT_CODE_STACK_FOLDER_NOT_FOUND=10
EXIT_CODE_STACK_FOLDER_NAME_NOT_VALID=11
EXIT_CODE_NOT_SAFE_STACK_STATE=12
EXIT_CODE_LAMBDA_FOLDER_NOT_FOUND=13
EXIT_CODE_LAMBDA_FOLDER_NAME_NOT_VALID=14
EXIT_CODE=$EXIT_CODE_SUCCESS


#---------------------------
# functions
#---------------------------
IsParameterHelp ()
{
    echo "-> IsParameterHelp ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        echo "<- IsParameterHelp (TRUE)"
        return $TRUE
    else
        echo "<- IsParameterHelp (FALSE)"
        return $FALSE
    fi
}

CheckNumberOfParameters ()
{
    echo "-> CheckNumberOfParameters ($@)"
    local LCL_EXPECTED_NUMBER_OF_PARAMS=$1
    local LCL_ALL_PARAMS=($@)
    local LCL_PARAMETERS_PASSED_IN=(${LCL_ALL_PARAMS[@]:1:$#})
    if [ $LCL_EXPECTED_NUMBER_OF_PARAMS -ne ${#LCL_PARAMETERS_PASSED_IN[@]} ]; then
        echo "ERROR: invalid number of parameters."
        echo "  expected number:  $LCL_EXPECTED_NUMBER_OF_PARAMS"
        echo "  passed in number: ${#LCL_PARAMETERS_PASSED_IN[@]}"
        echo "  parameters passed in: ${LCL_PARAMETERS_PASSED_IN[@]}"
        echo "<- CheckNumberOfParameters (FALSE)"
        return $FALSE
    else
        echo "<- CheckNumberOfParameters (TRUE)"
        return $TRUE
    fi
}

PrintUsageAndExitWithCode ()
{
    local LOCAL_EXIT_CODE=$1
    local LOCAL_ERROR_MESSAGE=$2
    if [[ $LOCAL_ERROR_MESSAGE != "" ]]; then
        echo "ERROR: $LOCAL_ERROR_MESSAGE"
    fi
    echo ""
    echo "$0 configures ssh on Mac/Linux/Unix to work with git"
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMS parameters."
    echo "  $0 -a <user name> <ssh service> - create ssh keys and adds the private key to the shh agent"
    echo "  $0 -d <user name> <ssh service> - removes ssh private key from ssh agent and deletes the ssh keys"
    echo "  Example: $0 -a alexbigkid github"
    echo "  Example: $0 -d alexbigkid github"
    echo "  $0 --help           - display this info"
    exit $LOCAL_EXIT_CODE
}

CreateSshKeys ()
{
    echo "-> CreateSshKeys ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_KEY_FULL_NAME=$1
    local LOCAL_SSH_KEY_COMMENT=$2
    echo "   \$LOCAL_SSH_KEY_FULL_NAME = $LOCAL_SSH_KEY_FULL_NAME"
    echo "   \$LOCAL_SSH_KEY_COMMENT   = $LOCAL_SSH_KEY_COMMENT"

    # createSshKeys if does not exist
    if [ ! -f $LOCAL_SSH_KEY_FULL_NAME ]; then
        echo "   generating $LOCAL_SSH_KEY_FULL_NAME key pair with comment: \"$LOCAL_SSH_KEY_COMMENT\""
        ssh-keygen -C "$LOCAL_SSH_KEY_COMMENT" -P "" -f $LOCAL_SSH_KEY_FULL_NAME
        LOCAL_EXIT_CODE=$?
    else
        echo "   $LOCAL_SSH_KEY_FULL_NAME ssh key already exist."
    fi

    echo "<- CreateSshKeys ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

DeleteSshKeys ()
{
    echo "-> DeleteSshKeys ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_PRIVATE_KEY_FULL_NAME=$1
    local LOCAL_SSH_PUBLIC_KEY_FULL_NAME="$LOCAL_SSH_PRIVATE_KEY_FULL_NAME.pub"
    echo "   \$LOCAL_SSH_PRIVATE_KEY_FULL_NAME = $LOCAL_SSH_PRIVATE_KEY_FULL_NAME"

    echo "   deleting private key: $LOCAL_SSH_PRIVATE_KEY_FULL_NAME and public key: $LOCAL_SSH_PUBLIC_KEY_FULL_NAME ..."
    rm $LOCAL_SSH_PRIVATE_KEY_FULL_NAME $LOCAL_SSH_PUBLIC_KEY_FULL_NAME
    LOCAL_EXIT_CODE=$?

    echo "<- DeleteSshKeys ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

AddSshKeyToSshConfig ()
{
    echo "-> AddSshKeyToSshConfig ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_DIR=$1
    local LOCAL_SSH_PRIVATE_KEY=$2
    local LOCAL_SSH_CONFIG_FILE="$LOCAL_SSH_DIR/config"
    local LOCAL_USER=$3
    echo "   \$LOCAL_SSH_DIR = $LOCAL_SSH_DIR"
    echo "   \$LOCAL_SSH_PRIVATE_KEY = $LOCAL_SSH_PRIVATE_KEY"
    echo "   \$LOCAL_USER = $LOCAL_USER"
    echo "   \$LOCAL_SSH_CONFIG_FILE = $LOCAL_SSH_CONFIG_FILE"

    # find IdentityFile in the config file
    FIND_CONTENT=$(grep "IdentityFile $LOCAL_SSH_DIR/$SSH_PRIVATE_KEY_NAME" $LOCAL_SSH_CONFIG_FILE)
    if [[ $FIND_CONTENT == "" ]]; then
        echo "   inserting config for ssh key: $SSH_DIR/$SSH_PRIVATE_KEY_NAME to $SSH_DIR/config file ..."
        LOCAL_CONFIG_TO_INSERT=$"$BEGIN_OF_CONFIG_SECTION $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY
Host $LOCAL_SSH_PRIVATE_KEY
	HostName $LOCAL_SSH_PRIVATE_KEY
	User $LOCAL_USER
	PreferredAuthentications publickey
	IdentityFile $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY
	IdentitiesOnly yes
	UseKeychain yes
	AddKeysToAgent yes
$END___OF_CONFIG_SECTION $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY

"
        ex -sc '1i|'"$LOCAL_CONFIG_TO_INSERT"'' -cx $LOCAL_SSH_CONFIG_FILE
        LOCAL_EXIT_CODE=$?
    else
        echo "   $LOCAL_SSH_DIR/$SSH_PRIVATE_KEY_NAME is already in the $LOCAL_SSH_CONFIG_FILE file"
        echo "   \$FIND_CONTENT = $FIND_CONTENT"
    fi

    echo "<- AddSshKeyToSshConfig ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}


RemoveSshKeyFromSshConfig ()
{
    echo "-> RemoveSshKeyFromSshConfig ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_DIR=$1
    local LOCAL_SSH_PRIVATE_KEY=$2
    local LOCAL_SSH_CONFIG_FILE="$LOCAL_SSH_DIR/config"
    local LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE="$BEGIN_OF_CONFIG_SECTION $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY"
    local LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE="$END___OF_CONFIG_SECTION $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY"
    echo "   \$LOCAL_SSH_DIR = $LOCAL_SSH_DIR"
    echo "   \$LOCAL_SSH_PRIVATE_KEY = $LOCAL_SSH_PRIVATE_KEY"
    echo "   \$LOCAL_SSH_CONFIG_FILE = $LOCAL_SSH_CONFIG_FILE"

    # find IdentityFile in the config file
    FIND_CONTENT=$(grep "IdentityFile $LOCAL_SSH_DIR/$SSH_PRIVATE_KEY_NAME" $LOCAL_SSH_CONFIG_FILE)
    if [[ $FIND_CONTENT != "" ]]; then
        echo "   deleting section for ssh key: $SSH_DIR/$SSH_PRIVATE_KEY_NAME in $LOCAL_SSH_CONFIG_FILE file ..."
        # escaping all / with \ since sed does not like them
        local LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE_ESC=$(sed 's/[\/]/\\\//g' <<<$LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE)
        local LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE_ESC=$(sed 's/[\/]/\\\//g' <<<$LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE)
        echo "   LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE_ESC = $LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE_ESC"
        echo "   LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE_ESC = $LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE_ESC"
        # removing added section and the leading blank lines afterwards, as a safety config.backup is created
        sed -i .backup -e "/$LOCAL_BEGIN_OF_CONFIG_SECTION_TO_REMOVE_ESC/,/$LOCAL_END___OF_CONFIG_SECTION_TO_REMOVE_ESC/d" -e '/./,$!d' $LOCAL_SSH_CONFIG_FILE
        LOCAL_EXIT_CODE=$?
    fi

    echo "<- RemoveSshKeyFromSshConfig ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

CreatePlistFileInAgentDirectory()
{
    echo "-> CreatePlistFileInAgentDirectory ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_LAUNCH_AGENT_DIR=$1
    local LOCAL_PLIST_SERVICE_LABEL=$2
    local LOCAL_SSH_KEY_FULL_NAME=$3
    local LOCAL_PLIST_FULL_NAME="$LOCAL_LAUNCH_AGENT_DIR/$LOCAL_PLIST_SERVICE_LABEL.plist"
    echo "   \$LOCAL_LAUNCH_AGENT_DIR = $LOCAL_LAUNCH_AGENT_DIR"
    echo "   \$LOCAL_PLIST_SERVICE_LABEL = $LOCAL_PLIST_SERVICE_LABEL"
    echo "   \$LOCAL_SSH_KEY_FULL_NAME = $LOCAL_SSH_KEY_FULL_NAME"
    echo "   \$LOCAL_PLIST_FULL_NAME = $LOCAL_PLIST_FULL_NAME"

    # check the agent directory exists
    local LOCAL_UNAME="$(uname -s)"
    if [ $LOCAL_UNAME == "Darwin" ]; then
        # MacOS, safe to continue and create directory
        mkdir -p $LOCAL_LAUNCH_AGENT_DIR
    else
        echo "ERROR: $LOCAL_LAUNCH_AGENT_DIR does not exist. Invalid environment? This script is written for Mac OSX"
        LOCAL_EXIT_CODE=$EXIT_CODE_GENERAL_ERROR
        echo "<- CreatePlistFileInAgentDirectory ($LOCAL_EXIT_CODE)"
        return $LOCAL_EXIT_CODE
    fi

    # check if the plist already exist
    if [[ -f $LOCAL_PLIST_FULL_NAME ]]; then
        echo "   $LOCAL_PLIST_FULL_NAME file already exist. Exiting without creating plist file..."
    else
        echo "   Creating $LOCAL_PLIST_FULL_NAME file..."
        cat > $LOCAL_PLIST_FULL_NAME<<EOF_PLIST_FILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LOCAL_PLIST_SERVICE_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>ssh-add</string>
        <string>-K</string>
        <string>$LOCAL_SSH_KEY_FULL_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>TimeOut</key>
    <integer>30</integer>
</dict>
</plist>
EOF_PLIST_FILE
        LOCAL_EXIT_CODE=$?
    fi

    echo "<- CreatePlistFileInAgentDirectory ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

DeletePlistFileInAgentDirectory ()
{
    echo "-> DeletePlistFileInAgentDirectory ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_LAUNCH_AGENT_DIR=$1
    local LOCAL_PLIST_SERVICE_LABEL=$2
    local LOCAL_PLIST_FULL_NAME="$LOCAL_LAUNCH_AGENT_DIR/$LOCAL_PLIST_SERVICE_LABEL.plist"
    echo "   \$LOCAL_LAUNCH_AGENT_DIR = $LOCAL_LAUNCH_AGENT_DIR"
    echo "   \$LOCAL_PLIST_SERVICE_LABEL = $LOCAL_PLIST_SERVICE_LABEL"
    echo "   \$LOCAL_SSH_KEY_FULL_NAME = $LOCAL_SSH_KEY_FULL_NAME"


    if [[ -f $LOCAL_PLIST_FULL_NAME ]]; then
        echo "   deleting plist file $LOCAL_PLIST_FULL_NAME ..."
        rm $LOCAL_PLIST_FULL_NAME
        LOCAL_EXIT_CODE=$?
    fi

    echo "<- CreatePlistFileInAgentDirectory ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE

}

StartShhKeyWithLaunchAgent ()
{
    echo "-> StartShhKeyWithLaunchAgent ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_LAUNCH_AGENT_DIR=$1
    local LOCAL_PLIST_SERVICE_LABEL=$2
    local LOCAL_PLIST_FULL_NAME="$LOCAL_LAUNCH_AGENT_DIR/$LOCAL_PLIST_SERVICE_LABEL.plist"
    echo "   \$LOCAL_LAUNCH_AGENT_DIR = $LOCAL_LAUNCH_AGENT_DIR"
    echo "   \$LOCAL_PLIST_SERVICE_LABEL = $LOCAL_PLIST_SERVICE_LABEL"
    echo "   \$LOCAL_PLIST_FULL_NAME = $LOCAL_PLIST_FULL_NAME"

    IS_SSH_AGENT_RUNNING=$(launchctl list | grep $LOCAL_PLIST_SERVICE_LABEL)
    if [[ $IS_SSH_AGENT_RUNNING == "" ]]; then
        # check the plist file exists
        if [[ -f $LOCAL_PLIST_FULL_NAME ]]; then
            echo "   checking $LOCAL_PLIST_SERVICE_LABEL service already running ..."
            IS_LAUNCHCTL_SERVICE_RUNNING=$(launchctl list $LOCAL_PLIST_SERVICE_LABEL)
            LOCAL_EXIT_CODE=$?
            if [[ $LOCAL_EXIT_CODE -ne 0 ]]; then
                echo "   launchctl load -w $LOCAL_PLIST_FULL_NAME"
                launchctl load -w $LOCAL_PLIST_FULL_NAME
                LOCAL_EXIT_CODE=$?
                if [[ $LOCAL_EXIT_CODE -eq 0 ]]; then
                    echo "   launchctl start $LOCAL_PLIST_SERVICE_LABEL"
                    launchctl start $LOCAL_PLIST_SERVICE_LABEL
                    LOCAL_EXIT_CODE=$?
                fi
            else
                echo "   $LOCAL_PLIST_SERVICE_LABEL service is already running ..."
            fi
        else
            echo "   $LOCAL_PLIST_FULL_NAME does not exist ..."
            LOCAL_EXIT_CODE=$EXIT_CODE_GENERAL_ERROR
        fi
    else
        echo "   $IS_SSH_AGENT_RUNNING is already running ..."
    fi

    echo "<- StartShhKeyWithLaunchAgent ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

StopShhKeyWithLaunchAgent ()
{
    echo "-> StopShhKeyWithLaunchAgent ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_LAUNCH_AGENT_DIR=$1
    local LOCAL_PLIST_SERVICE_LABEL=$2
    local LOCAL_PLIST_FULL_NAME="$LOCAL_LAUNCH_AGENT_DIR/$LOCAL_PLIST_SERVICE_LABEL.plist"
    echo "   \$LOCAL_LAUNCH_AGENT_DIR = $LOCAL_LAUNCH_AGENT_DIR"
    echo "   \$LOCAL_PLIST_SERVICE_LABEL = $LOCAL_PLIST_SERVICE_LABEL"
    echo "   \$LOCAL_PLIST_FULL_NAME = $LOCAL_PLIST_FULL_NAME"

    IS_SSH_AGENT_RUNNING=$(launchctl list | grep $LOCAL_PLIST_SERVICE_LABEL)
    if [[ $IS_SSH_AGENT_RUNNING != "" ]]; then
        echo "   launchctl $LOCAL_PLIST_SERVICE_LABEL service is running ..."
        echo "   stopping launchctl $LOCAL_PLIST_SERVICE_LABEL service ..."
        launchctl stop $LOCAL_PLIST_SERVICE_LABEL
        LOCAL_EXIT_CODE=$?
        echo "   unloading launchctl $LOCAL_PLIST_SERVICE_LABEL service ..."
        launchctl unload -w $LOCAL_PLIST_FULL_NAME
        LOCAL_EXIT_CODE=$?
        echo "   done stopping and unloading $LOCAL_PLIST_SERVICE_LABEL service."
    fi

    echo "<- StopShhKeyWithLaunchAgent ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

EnsureSshKeyIsLoaded ()
{
    echo "-> EnsureSshKeyIsLoaded ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_DIR=$1
    local LOCAL_SSH_PRIVATE_KEY=$2
    local LOCAL_SSH_PUBLIC_KEY="$LOCAL_SSH_PRIVATE_KEY.pub"
    echo "   \$LOCAL_SSH_DIR            = $LOCAL_SSH_DIR"
    echo "   \$LOCAL_SSH_PRIVATE_KEY    = $LOCAL_SSH_PRIVATE_KEY"
    echo "   \$LOCAL_SSH_PUBLIC_KEY     = $LOCAL_SSH_PUBLIC_KEY"

    echo "   checking ssh agent is loaded with the $LOCAL_SSH_PUBLIC_KEY key ..."
    LOCAL_SSH_KEY_LOADED=$(ssh-add -L $LOCAL_SSH_PUBLIC_KEY)
    echo "   \$LOCAL_SSH_KEY_LOADED     = $LOCAL_SSH_KEY_LOADED"
    LOCAL_SSH_PUBLIC_KEY=$(cat $LOCAL_SSH_DIR/$LOCAL_SSH_PUBLIC_KEY)
    echo "   \$LOCAL_SSH_PUBLIC_KEY     = $LOCAL_SSH_PUBLIC_KEY"
    if [[ $LOCAL_SSH_KEY_LOADED != $LOCAL_SSH_PUBLIC_KEY ]]; then
        echo "   laoding ssh key to the ssh agent ..."
        local LOCAL_LOAD_SSH_KEY_TO_SSH_AGENT=$(ssh-add -K $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY)
        LOCAL_EXIT_CODE=$?
    fi

    echo "<- EnsureSshKeyIsLoaded ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

EnsureSshKeyIsUnloaded ()
{
    echo "-> EnsureSshKeyIsUnloaded ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_DIR=$1
    local LOCAL_SSH_PRIVATE_KEY=$2
    echo "   \$LOCAL_SSH_DIR            = $LOCAL_SSH_DIR"
    echo "   \$LOCAL_SSH_PRIVATE_KEY    = $LOCAL_SSH_PRIVATE_KEY"

    echo "   unloading the $LOCAL_SSH_PUBLIC_KEY key from ssh agent ..."
    ssh-add -d $LOCAL_SSH_DIR/$LOCAL_SSH_PRIVATE_KEY

    echo "<- EnsureSshKeyIsUnloaded ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

PrintSshPublicKeyAdditionUserInstruction ()
{
    echo "-> PrintSshPublicKeyAdditionUserInstruction ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_PUB_KEY_FILE_NAME=$1
    echo "   \$LOCAL_SSH_PUB_KEY_FILE_NAME = $LOCAL_SSH_PUB_KEY_FILE_NAME"

    echo -e "${PURPLE}   Please add the file content: \"$LOCAL_SSH_PUB_KEY_FILE_NAME\" to your git account:${NC}"
    echo -e "${PURPLE}     1. Login to your git account${NC}"
    echo -e "${PURPLE}     2. Click on your account icon, top right corner.${NC}"
    echo -e "${PURPLE}     3. Select Security from the drop down menu.${NC}"
    echo -e "${PURPLE}     4. Click on the \"SSH public keys\" on the left frame.${NC}"
    echo -e "${PURPLE}     5. Click on Add.${NC}"
    echo -e "${PURPLE}     6. Name/describe your public key e.g. your computer you are establishing connection from.${NC}"
    echo -e "${PURPLE}     7. Paste content of the file \"$LOCAL_SSH_PUB_KEY_FILE_NAME\" into the \"Key Data\" field.${NC}"
    echo -e "${PURPLE}     8. Please pay attention to the ending of the ssh pub key file data. The data should end with your email with no line breaks on the end.${NC}"
    echo -e "${PURPLE}     9. Click Save. Congrats, you are done!${NC}"

    echo "<- PrintSshPublicKeyAdditionUserInstruction ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}

PrintSshPublicKeyRemovalUserInstruction ()
{
    echo "-> PrintSshPublicKeyRemovalUserInstruction ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_SSH_PUB_KEY_FILE_NAME=$1
    echo "   \$LOCAL_SSH_PUB_KEY_FILE_NAME = $LOCAL_SSH_PUB_KEY_FILE_NAME"

    echo -e "${PURPLE}   Please remove the file content: \"$LOCAL_SSH_PUB_KEY_FILE_NAME\" from your git account:${NC}"
    echo -e "${PURPLE}     1. Login to your git account${NC}"
    echo -e "${PURPLE}     2. Click on your account icon, top right corner.${NC}"
    echo -e "${PURPLE}     3. Select Security from the drop down menu.${NC}"
    echo -e "${PURPLE}     4. Click on the \"SSH public keys\" on the left frame.${NC}"
    echo -e "${PURPLE}     5. find the public key you would like to remove.${NC}"
    echo -e "${PURPLE}     6. Click on the red cross next to the public key you would like to remove.${NC}"

    echo "<- PrintSshPublicKeyRemovalUserInstruction ($LOCAL_EXIT_CODE)"
    return $LOCAL_EXIT_CODE
}


# ----------
# main
# ----------
echo ""
echo "-> $0 ($@)"

IsParameterHelp $# $1 && PrintUsageAndExitWithCode $EXIT_CODE_SUCCESS
CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMS $@ || PrintUsageAndExitWithCode $EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS "Invalid number of parameters"


getopts ":a:d:" opt;
case $opt in
    a) echo "   Adding $USER_NAME user ..."
    echo "   ----------------------------------"
    CreateSshKeys $SSH_DIR/$SSH_PRIVATE_KEY_NAME $SSH_PRIVATE_KEY_NAME || PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR "CreateSshKeys failed"
    AddSshKeyToSshConfig $SSH_DIR $SSH_PRIVATE_KEY_NAME $USER_NAME || PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR "AddSshKeyToSshConfig failed"
    CreatePlistFileInAgentDirectory $LAUNCH_AGENT_DIR $PLIST_SERVICE_NAME $SSH_DIR/$SSH_PRIVATE_KEY_NAME || PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR "CreatePlistFileInAgentDirectory failed"
    StartShhKeyWithLaunchAgent $LAUNCH_AGENT_DIR $PLIST_SERVICE_NAME || PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR "StartShhKeyWithLaunchAgent failed"
    EnsureSshKeyIsLoaded $SSH_DIR $SSH_PRIVATE_KEY_NAME || PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR "failed the check of ssh agent runnning with the $SSH_PRIVATE_KEY_NAME key."
    PrintSshPublicKeyAdditionUserInstruction $SSH_DIR/$SSH_PUBLIC_KEY_NAME
    ;;
    d) echo "   Deleting $USER_NAME user ..."
    echo "   ------------------------------------"
    EnsureSshKeyIsUnloaded $SSH_DIR $SSH_PRIVATE_KEY_NAME
    StopShhKeyWithLaunchAgent $LAUNCH_AGENT_DIR $PLIST_SERVICE_NAME
    DeletePlistFileInAgentDirectory $LAUNCH_AGENT_DIR $PLIST_SERVICE_NAME
    RemoveSshKeyFromSshConfig $SSH_DIR $SSH_PRIVATE_KEY_NAME
    DeleteSshKeys $SSH_DIR/$SSH_PRIVATE_KEY_NAME
    PrintSshPublicKeyRemovalUserInstruction $SSH_DIR/$SSH_PUBLIC_KEY_NAME
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER "Not valid parameters"
    ;;
esac

echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
