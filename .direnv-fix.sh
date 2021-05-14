#!/bin/bash

#######################################
# User modifiable params
#######################################

# The path to: direnv
direnv_path="${HOME}/direnv"

# The path to: bash-preexec.sh
bash_preexec_path="${HOME}/bash-preexec.sh"

# The command that will be run to check the $PATH is working.
test_command='ls'

# This is the path that we will use when the true path is corrupted.  This should re-enable command execution.
# Once command execution is re-enabled, we will 
recovery_path='/mingw64/bin:/usr/local/bin:/usr/bin:/bin:/mingw64/bin:/usr/bin'

# Logging to diagnose issues.
enable_debug_logging=0
# Uncomment the below line to enable logging.
# enable_debug_logging=1

#######################################
# End: User modifiable params
#######################################


get_log_width() {
    local  __resultvar=$1
    local  resulting_width=0

    if [ -z "${COLUMNS}" ]; 
    then     
        if command -v tput; 
        then
            resulting_width=$(tput cols)
        else
            resulting_width=80
        fi
    else
        resulting_width="${COLUMNS}"
    fi

    resulting_width=$((resulting_width - 6))
    eval $__resultvar="'$resulting_width'"
}

dfx_echo() { echo -e "\e[0m${1}${2}\e[0m"; }
dfx_event() { (( enable_debug_logging == 1)) && dfx_echo "\e[1m\e[32m"  "${1}"; }
dfx_log() { (( enable_debug_logging == 1)) && dfx_echo "\e[34m" "${1}"; }
dfx_path() { (( enable_debug_logging == 1)) && dfx_echo "\e[1m\e[36m" "${1}"; }
dfx_error() { (( enable_debug_logging == 1)) && dfx_echo "\e[1m\e[31m" "${1}"; }
dfx_test() { (( enable_debug_logging == 1)) && dfx_echo "\e[1m\e[33m" "${1}"; }

dfx_event '[.direnv-fix.sh] [ENTER]'

#######################################
# Error handling for command testing.  This is where we will fix the path if it is broken.
# GLOBALS:
#   PATH - will modify the path to adjust direnv path modifications.
# ARGUMENTS:
#   None.
# OUTPUTS:
#   None.
# RETURN:
#   0 if we save the path.  If non-zero... God help us.
#######################################
direnv_fix_catch() {
    dfx_error '[.direnv-fix.sh] [direnv_fix_catch()] [ENTER] --- Its a trap! ---'

    local log_width
    get_log_width log_width

    dfx_log '[.direnv-fix.sh] [direnv_fix_catch()] [LOG] Recording broken path for correction later.'
    # Cache the current (broken) path.  We will need to restore and reformat this later.
    local direnv_new_path="$PATH" # 
    dfx_path "**** Broken path [trimmed]"
    dfx_path "**** ${direnv_new_path:0:log_width}"
    dfx_path "****"

    dfx_log '[.direnv-fix.sh] [direnv_fix_catch()] [LOG] Resetting path to known good state.'
    # Restoring the backup path.  This should enable sed for the next step.
    # shellcheck source=src/util.sh
    PATH="$recovery_path"
    export PATH
    dfx_path "**** Temporary fix path [trimmed]"
    dfx_path "**** ${PATH:0:log_width}"
    dfx_path "****" 

    dfx_log '[.direnv-fix.sh] [direnv_fix_catch()] [LOG] Reformatting new path.'
    # Using _ as the delimiter, sed will make the following replacements:
    # \     ->   /
    # A:    ->   /a
    # B:    ->   /b
    # C:    ->   /c
    # D:    ->   /d
    # E:    ->   /e
    # ;     ->   :
    # /c/Program Files/Git/ -> /
    # :/usr/bin:/usr/bin:   -> :/usr/bin:/bin:
    PATH=$(echo "${direnv_new_path}" | sed -e 's_\\_/_g' -e 's_A:_/a_g' -e 's_B:_/b_g' -e 's_C:_/c_g' -e 's_D:_/d_g' -e 's_E:_/e_g' -e 's_;_:_g' -e 's_/c/Program Files/Git/_/_g' -e 's_:/usr/bin:/usr/bin:_:/usr/bin:/bin:_g' )
    # Reset the path.
    export PATH
    dfx_path "**** Fixed path [trimmed]"
    dfx_path "**** ${PATH:0:log_width}"
    dfx_path "****"

    dfx_test '[.direnv-fix.sh] [direnv_fix_catch()] [TEST] Executing test command and exiting.'
    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
}

#######################################
# Tests for broken path.
# GLOBALS:
#   PATH - will modify the path to adjust direnv path modifications.
# ARGUMENTS:
#   None.
# OUTPUTS:
#   None.
# RETURN:
#   0 if we succeed, non-zero on error.
#######################################
preexec() 
{        
    dfx_event '[.direnv-fix.sh] [preexec()] [ENTER]'

    trap 'direnv_fix_catch' ERR    
    
    dfx_test '[.direnv-fix.sh] [preexec()] [TEST] Executing test command and exiting.'
    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
}

#######################################
# Tests for broken path.
# GLOBALS:
#   PATH - will modify the path to adjust direnv path modifications.
# ARGUMENTS:
#   None.
# OUTPUTS:
#   None.
# RETURN:
#   0 if we succeed, non-zero on error.
#######################################
precmd() {    
    dfx_event '[.direnv-fix.sh] [precmd()] [ENTER]'

    trap 'direnv_fix_catch' ERR    
    
    dfx_test '[.direnv-fix.sh] [precmd()] [TEST] Executing test command and exiting.'
    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
}

dfx_log '[.direnv-fix.sh] [LOG] eval "$('"${direnv_path}"' hook bash)"'

# Hooks direnv into the prompt command
eval "$("${direnv_path}" hook bash)"

dfx_log '[.direnv-fix.sh] [LOG] source '"${bash_preexec_path}"

# Hooks bash-preexec into prompt command
# shellcheck source=./bash-preexec.sh
source "${bash_preexec_path}"

dfx_event '[.direnv-fix.sh] [EXIT]'