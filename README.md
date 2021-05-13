# bash-preexec

**This fork changes the default behaviour of bash-preexec - specifically the order of `$PROMP_COMMAND`.**  See [below](##pre-existing-installations-of-bash-preexec ).

## Background

This is a fork specifically to work around an [issue](https://github.com/direnv/direnv/issues/796) occuring with direnv on Windows using git bash - it should not be used generally.  

## Contents

### `bash-preexec.sh`

*very slightly* modified from the upstream version.  The modification re-orders how the pre-command hooks get called.  This is important because if `direnv` mangles our path, we need to correct the path *as soon as possible*, hence the change.

### `direnv-fix.sh`

The path fix.  You should review this before you hook it up to your system.  Basically:

- It tests before and after commands to determine if the `$PATH` is broken by running `ls`.  You can configure your own test command in the script.
- If it fails, we assume the `$PATH` is broken and:
  - Cache the broken `$PATH`.  The formatting is bad, but it still has the paths you want.
  - Restore to a known good `$PATH`: `/mingw64/bin:/usr/local/bin:/usr/bin:/bin:/mingw64/bin:/usr/bin`
  - Use `sed` to fix the formatting of the cached, broken `$PATH`.
  - Restore the now correctly-formatted `$PATH`
- This is all accomplished using an error trap.

## Installation

- Download the `.direnv-fix` and `bash-preexec.sh` script from this repository.
- Place both scripts into your `$HOME` directory, or wherever you want.
- Add the following to your `.bashrc`:

  ``` sh
  source "${HOME}/.direnv-fix.sh"
  ```

- Open `direnv-fix.sh` and modify the following parameters:

  ``` sh
  # The path to: direnv
  direnv_path="${HOME}/direnv"

  # The path to: bash-preexec.sh
  bash_preexec_path="${HOME}/bash-preexec.sh"
  ```

- Restart your shell.

## Pre-existing installations of bash-preexec

This repository changes the way that `bash-preexec.sh` updates the `$PROMPT_COMMAND` variable.  In the original repository, the `$PROMPT_COMMAND` variable is **prepended** with the `bash-preexec precmd` functions.  However, to work-around the direnv error, we need `precmd` to run *after* direnv.  This change can be seen on line 310 of `bash-preexec.sh`.
