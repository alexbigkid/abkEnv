#-------------------------
# file for aliases
#-------------------------
USER_ENV=$HOME/env
if [ -f $USER_ENV/bash_aliases.sh ]; then
    source $USER_ENV/bash_aliases.sh
fi

#-------------------------
# abk prompt config
#-------------------------
if [ -f $USER_ENV/abk_prompt.sh ]; then
    source $USER_ENV/abk_prompt.sh
fi

#-------------------------
# abk if new sqlite is installed and is not in the $PATH yet, include it
#-------------------------
SQLITE_BIN=/usr/local/opt/sqlite/bin
if [ -d $SQLITE_BIN ] && [[ ! ":$PATH:" == *":$SQLITE_BIN:"* ]]; then
    # echo "\$SQLITE_BIN ($SQLITE_BIN) exist"
    export PATH="$SQLITE_BIN:$PATH"
    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"
fi

#-------------------------
# if users bin directory exist and is not in the $PATH yet, include it
#-------------------------
USER_BIN="$HOME/bin"
if [ -d $USER_BIN ] && [[ ! ":$PATH:" == *":$USER_BIN:"* ]]; then
    # echo "\$USER_BIN ($USER_BIN) exist"
    export PATH="$USER_BIN:$PATH"
fi
