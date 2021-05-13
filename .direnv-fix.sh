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

#######################################
# End: User modifiable params
#######################################

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
    # Cache the current (broken) path.  We will need to restore and reformat this later.
    direnv_new_path="$PATH" # 

    # Restoring the backup path.  This should enable sed for the next step.
    # shellcheck source=src/util.sh
    PATH="$recovery_path"
    export PATH
    
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

    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
}

#######################################
# Records the path prior to direnv modifying it, so that it can be adjusted after the changes.
# This allows the fixing of incorrect formatting on Windows.
# https://github.com/direnv/direnv/issues/796
#
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
    trap 'direnv_fix_catch' ERR    
    
    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
    return $?
}

#######################################
# Restores the pre-direnv path to enable command execution, and then corrects the path formatting.
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
    trap 'direnv_fix_catch' ERR    
    
    # Execute test_command to set the exit code appropriately.
    $test_command &> /dev/null
    return $?
}

# Hooks direnv into the prompt command
eval "$("${direnv_path}" hook bash)"

# Hooks bash-preexec into prompt command
# shellcheck source=./bash-preexec.sh
source "${bash_preexec_path}"
