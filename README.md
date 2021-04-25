# bash-preexec

**This fork changes the default behaviour of bash-preexec - specifically the order of `$PROMP_COMMAND`.**  See [below](##pre-existing-installations-of-bash-preexec ).
## Background
This is a fork specifically to work around an [issue](https://github.com/direnv/direnv/issues/796) occuring with direnv on Windows using git bash - it should not be used generally.  

## Installation 
- Download the `.bashrc` and `bash-preexec.sh` script from this repository.
- Append the contents of `.bashrc` to your own `${HOME}/.bashrc`.
- Update the first 2 append lines to the correct paths for your system:
  ``` bash
  direnv_path="direnv"
  bash_preexec_path="bash-preexec.sh"
  ```

## Pre-existing installations of bash-preexec

This repository changes the way that `bash-preexec.sh` updates the `$PROMPT_COMMAND` variable.  In the original repository, the `$PROMPT_COMMAND` variable is **prepended** with the `bash-preexec precmd` functions.  However, to work-around the direnv error, we need `precmd` to run *after* direnv.  This change can be seen on line 310 of `bash-preexec.sh`.  
