#!/bin/bash

# -----------------------------------------------------------------------------
# Color difinitions
# -----------------------------------------------------------------------------
ABK_COLOR=(
    '\033[0;30m'
    '\033[0;34m'
    '\033[0;36m'
    '\033[1;30m'
    '\033[0;32m'
    '\033[1;34m'
    '\033[0;37m'
    '\033[1;36m'
    '\033[1;32m'
    '\033[1;35m'
    '\033[1;31m'
    '\033[0;33m'
    '\033[0;35m'
    '\033[0;31m'
    '\033[1;37m'
    '\033[1;33m'
)
# 0 - 15 colors
NC='\033[0m'

# -----------------------------------------------------------------------------
# Text definitions
# -----------------------------------------------------------------------------
ABK_PUSH_IT_0=(
    '  __   __    ___  _  _    __  ___     __  _    _  ___  ___   __  __  __  ___ '
    ' (  ) (  )  (  _)( \/ )  (  )/ __)   (  )( \/\/ )(  _)/ __) /  \(  \/  )(  _)'
    ' /__\  )(__  ) _) )  (    )( \__ \   /__\ \    /  ) _)\__ \( () ))    (  ) _)'
    '(_)(_)(____)(___)(_/\_)  (__)(___/  (_)(_) \/\/  (___)(___/ \__/(_/\/\_)(___)'
)

ABK_PUSH_IT_1=(
    "    |     '||                      ||                                                                          "
    "   |||     ||    ....  ... ...    ...   ....      ....   ... ... ...   ....   ....    ...   .. .. ..     ....  "
    "  |  ||    ||  .|...||  '|..'      ||  ||. '     '' .||   ||  ||  |  .|...|| ||. '  .|  '|.  || || ||  .|...|| "
    " .''''|.   ||  ||        .|.       ||  . '|..    .|' ||    ||| |||   ||      . '|.. ||   ||  || || ||  ||      "
    ".|.  .||. .||.  '|...' .|  ||.    .||. |'..|'    '|..'|'    |   |     '|...' |'..|'  '|..|' .|| || ||.  '|...' "
)

ABK_PUSH_IT_2=(
    '  /$$$$$$  /$$                           /$$                                                                                              '
    ' /$$__  $$| $$                          |__/                                                                                              '
    '| $$  \ $$| $$  /$$$$$$  /$$   /$$       /$$  /$$$$$$$        /$$$$$$  /$$  /$$  /$$  /$$$$$$   /$$$$$$$  /$$$$$$  /$$$$$$/$$$$   /$$$$$$ '
    '| $$$$$$$$| $$ /$$__  $$|  $$ /$$/      | $$ /$$_____/       |____  $$| $$ | $$ | $$ /$$__  $$ /$$_____/ /$$__  $$| $$_  $$_  $$ /$$__  $$'
    '| $$__  $$| $$| $$$$$$$$ \  $$$$/       | $$|  $$$$$$         /$$$$$$$| $$ | $$ | $$| $$$$$$$$|  $$$$$$ | $$  \ $$| $$ \ $$ \ $$| $$$$$$$$'
    '| $$  | $$| $$| $$_____/  >$$  $$       | $$ \____  $$       /$$__  $$| $$ | $$ | $$| $$_____/ \____  $$| $$  | $$| $$ | $$ | $$| $$_____/'
    '| $$  | $$| $$|  $$$$$$$ /$$/\  $$      | $$ /$$$$$$$/      |  $$$$$$$|  $$$$$/$$$$/|  $$$$$$$ /$$$$$$$/|  $$$$$$/| $$ | $$ | $$|  $$$$$$$'
    '|__/  |__/|__/ \_______/|__/  \__/      |__/|_______/        \_______/ \_____/\___/  \_______/|_______/  \______/ |__/ |__/ |__/ \_______/'
)

ABK_PUSH_IT_3=(
    '           _             _                                                    '
    '     /\   | |           (_)                                                   '
    '    /  \  | | _____  __  _ ___    __ ___      _____  ___  ___  _ __ ___   ___ '
    '   / /\ \ | |/ _ \ \/ / | / __|  / _\ \ \ /\ / / _ \/ __|/ _ \  |_ \ _ \ / _ \'
    '  / ____ \| |  __/>  <  | \__ \ | (_| |\ V  V /  __/\__ \ (_) | | | | | |  __/'
    ' /_/    \_\_|\___/_/\_\ |_|___/  \__,_| \_/\_/ \___||___/\___/|_| |_| |_|\___|'
)

ABK_PUSH_IT_4=(
    '   (      (                                                                 '
    '   )\     )\   (     )   (           )  (  (      (              )      (   '
    '((((_)(  ((_) ))\ ( /(   )\  (    ( /(  )\))(    ))\ (    (     (      ))\  '
    ' )\ _ )\  _  /((_))\()) ((_) )\   )(_))((_)()\  /((_))\   )\    )\    /((_) '
    ' (_)_\(_)| |(_)) ((_)\   (_)((_) ((_)_ _(()((_)(_)) ((_) ((_) _((_)) (_))   '
    '  / _ \  | |/ -_)\ \ /   | |(_-< / _\ |\ V  V // -_)(_-</ _ \|    \()/ -_)  '
    ' /_/ \_\ |_|\___|/_\_\   |_|/__/ \__,_| \_/\_/ \___|/__/\___/|_|_|_| \___|  '
)

ABK_PUSH_IT_5=(
    '  __   __    ____  _  _    __  ____     __   _  _  ____  ____   __   _  _  ____ '
    ' / _\ (  )  (  __)( \/ )  (  )/ ___)   / _\ / )( \(  __)/ ___) /  \ ( \/ )(  __)'
    '/    \/ (_/\ ) _)  )  (    )( \___ \  /    \\ /\ / ) _) \___ \(  O )/ \/ \ ) _) '
    '\_/\_/\____/(____)(_/\_)  (__)(____/  \_/\_/(_/\_)(____)(____/ \__/ \_)(_/(____)'
)

ABK_PUSH_IT_6=(
    '   _   _             _                                                    '
    '  /_\ | | _____  __ (_)___    __ ___      _____  ___  ___  _ __ ___   ___ '
    ' //_\\| |/ _ \ \/ / | / __|  / _\ \ \ /\ / / _ \/ __|/ _ \|  _ \ _ \ / _ \'
    '/  _  \ |  __/>  <  | \__ \ | (_| |\ V  V /  __/\__ \ (_) | | | | | |  __/'
    '\_/ \_/_|\___/_/\_\ |_|___/  \__,_| \_/\_/ \___||___/\___/|_| |_| |_|\___|'
)

ABK_PUSH_IT_7=(
    '    ___       ___       ___       ___            ___       ___            ___       ___       ___       ___       ___       ___       ___   '
    '   /\  \     /\__\     /\  \     /\__\          /\  \     /\  \          /\  \     /\__\     /\  \     /\  \     /\  \     /\__\     /\  \  '
    '  /::\  \   /:/  /    /::\  \   |::L__L        _\:\  \   /::\  \        /::\  \   /:/\__\   /::\  \   /::\  \   /::\  \   /::L_L_   /::\  \ '
    ' /::\:\__\ /:/__/    /::\:\__\ /::::\__\      /\/::\__\ /\:\:\__\      /::\:\__\ /:/:/\__\ /::\:\__\ /\:\:\__\ /:/\:\__\ /:/L:\__\ /::\:\__\'
    ' \/\::/  / \:\  \    \:\:\/  / \;::;/__/      \::/\/__/ \:\:\/__/      \/\::/  / \::/:/  / \:\:\/  / \:\:\/__/ \:\/:/  / \/_/:/  / \:\:\/  /'
    '   /:/  /   \:\__\    \:\/  /   |::|__|        \:\__\    \::/  /         /:/  /   \::/  /   \:\/  /   \::/  /   \::/  /    /:/  /   \:\/  / '
    '   \/__/     \/__/     \/__/     \/__/          \/__/     \/__/          \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/  '
)

ABK_PUSH_IT_8=(
    ' █████╗ ██╗     ███████╗██╗  ██╗    ██╗███████╗     █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗'
    '██╔══██╗██║     ██╔════╝╚██╗██╔╝    ██║██╔════╝    ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝'
    '███████║██║     █████╗   ╚███╔╝     ██║███████╗    ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  '
    '██╔══██║██║     ██╔══╝   ██╔██╗     ██║╚════██║    ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  '
    '██║  ██║███████╗███████╗██╔╝ ██╗    ██║███████║    ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗'
    '╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝    ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝'
)

ABK_PUSH_IT_MAIN_ARRAY=(
    ABK_PUSH_IT_0[@]
    ABK_PUSH_IT_1[@]
    ABK_PUSH_IT_2[@]
    ABK_PUSH_IT_3[@]
    ABK_PUSH_IT_4[@]
    ABK_PUSH_IT_5[@]
    ABK_PUSH_IT_6[@]
    ABK_PUSH_IT_7[@]
    ABK_PUSH_IT_8[@]
)


# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
GetRandomColor() {
    local LCL_RANDOM_NUMBER=$((RANDOM % ${#ABK_COLOR[@]}))
    # echo "LCL_RANDOM_NUMBER = $LCL_RANDOM_NUMBER"
    echo ${ABK_COLOR[$LCL_RANDOM_NUMBER]}
}

PrintRandomText() {
    local LCL_RANDOM_COLOR=$(GetRandomColor)
    local LCL_RANDOM_NUMBER=$((RANDOM % ${#ABK_PUSH_IT_MAIN_ARRAY[@]}))

    echo -e "${LCL_RANDOM_COLOR}"
    for i in "${!ABK_PUSH_IT_MAIN_ARRAY[$LCL_RANDOM_NUMBER][@]}"; do
        echo -e "$i"
    done
    echo -e "${NC}"
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

PrintRandomText

exit 0
