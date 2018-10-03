#-------------------------
#path config
#-------------------------
export PATH="$HOME/bin:$PATH"
#export PATH="/usr/local/opt/python/libexec/bin:$PATH"
#export PIP_TARGET=/Library/Python/2.7/site-packages
#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2
#export PYTHON=/usr/local/bin/python2
#pip completion --bash
#eval "`pip completion --bash`"

#-------------------------
# setting up abk environment
#-------------------------
if [ -f ~/env/bash_abk_env.sh ]; then
    . ~/env/bash_abk_env.sh
fi
