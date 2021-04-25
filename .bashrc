#!/bin/bash

#######################################
# Records the path prior to direnv modifying it, so that it can be adjusted after the changes.
# This allows the fixing of incorrect formatting on Windows.
# https://github.com/direnv/direnv/issues/796
#
# GLOBALS:
#   DIRENV_FIX_PATH - whether or not a subsequent precmd hook should fix the path.
#   DIRENV_OLD_PATH - the path prior to direnv modifying it.
# ARGUMENTS:
#   The terminal input.
# OUTPUTS:
#   None.
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
preexec() 
{ 
    # Check if input is a command that could trigger direnv to activate an environment
    relevant_commands=$(echo ${1} | grep 'cd\|direnv\|.envrc')

    # Set some environment variables so that we know in the precmd to update the path.
    if [ "$relevant_commands" == "" ] ; then
        export DIRENV_FIX_PATH=0
        export DIRENV_OLD_PATH=''
    else
        export DIRENV_FIX_PATH=1
        export DIRENV_OLD_PATH="$PATH"
    fi
}

#######################################
# Restores the pre-direnv path to enable command execution, and then corrects the path formatting.
# GLOBALS:
#   PATH - will modify the path to adjust direnv path modifications.
#   DIRENV_FIX_PATH - whether or not a subsequent precmd hook should fix the path.
#   DIRENV_OLD_PATH - the path prior to direnv modifying it.
# ARGUMENTS:
#   None.
# OUTPUTS:
#   None.
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
precmd() 
{ 
    # If we should fix the path:
    if [ "${DIRENV_FIX_PATH}" == "1" ] ; 
    then  
        # Cache the current (broken) path.
        direnv_new_path="${PATH}"        
        
        # Reset the path to the original, so that we have access to sed.
        export PATH="${DIRENV_OLD_PATH}" 
        
        # Then fix and re-set the new path.
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
        export PATH=$(echo "${direnv_new_path}" | sed -e 's_\\_/_g' -e 's_A:_/a_g' -e 's_B:_/b_g' -e 's_C:_/c_g' -e 's_D:_/d_g' -e 's_E:_/e_g' -e 's_;_:_g' -e 's_/c/Program Files/Git/_/_g' -e 's_:/usr/bin:/usr/bin:_:/usr/bin:/bin:_g' )
    fi
}

# Hooks direnv into the prompt command
eval "$(direnv hook bash)"
# Hooks bash-preexec into prompt command
source "bash-preexec.sh"
