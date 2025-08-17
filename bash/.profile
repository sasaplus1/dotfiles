#!/bin/sh
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  # NOTE: In POSIX sh, 'local' is undefined: SC3043

  [ -n "$__SOURCED_PROFILE" ] && return
  export __SOURCED_PROFILE=1
  readonly __SOURCED_PROFILE

  # In POSIX sh, 'source' in place of '.' is undefined: SC3046
  # shellcheck disable=SC1090
  __main_sh_path="$HOME/.sh_path"
  [ -r "$__main_sh_path" ] && . "$__main_sh_path"

  #-----------------------------------------------------------------------------

  # NOTE: tmux overwrite TERM_PROGRAM and TERM_PROGRAM_VERSION
  # ex: Terminal.app = Apple_Terminal, 440
  # ex: VSCode       = vscode, 1.68.1
  export ORIGINAL_TERM_PROGRAM="$TERM_PROGRAM"
  readonly ORIGINAL_TERM_PROGRAM
  export ORIGINAL_TERM_PROGRAM_VERSION="$TERM_PROGRAM_VERSION"
  readonly ORIGINAL_TERM_PROGRAM_VERSION

  # history settings
  export HISTSIZE=10000
  export HISTFILESIZE=10000
  export HISTTIMEFORMAT='%Y/%m/%d %T '
  export HISTCONTROL=ignoredups:erasedups

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  __main_ssh_agent_info="$HOME/.ssh-agent-info"

  # In POSIX sh, 'source' in place of '.' is undefined: SC3046
  # shellcheck disable=SC1090
  . "$__main_ssh_agent_info" 2>/dev/null

  command ssh-add -l >/dev/null 2>&1

  # ssh-add is unable to contact the authentication agent
  if [ "$?" -eq 2 ] && [ -x "$(command -v ssh-agent)" ]
  then
    eval "$(command ssh-agent -k)" 2>/dev/null

    # force remove
    unset SSH_AUTH_SOCK
    unset SSH_AGENT_PID
    rm -f "$__main_ssh_agent_info"

    eval "$(command ssh-agent | grep -v 'echo' | tee "$__main_ssh_agent_info")" 2>/dev/null
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # nvm {{{
  # if [ -z "${XDG_CONFIG_HOME-}" ]
  # then
  #   export NVM_DIR="$HOME/.nvm"
  # else
  #   export NVM_DIR="$XDG_CONFIG_HOME/nvm"
  # fi
  # }}}

  #-----------------------------------------------------------------------------

  # stop flow mode (disable C-s and C-q)
  # stty stop undef
  # stty start undef
  type stty >/dev/null 2>&1 && stty -ixon

  type vi >/dev/null 2>&1 && export EDITOR=vi
  type vim >/dev/null 2>&1 && export EDITOR=vim
  type less >/dev/null 2>&1 && export PAGER=less

  # NOTE: `$ man bash` outputs `UNSUPP: unsupported control character: 0x7` error
  # https://github.com/orgs/Homebrew/discussions/2506
  if type bat >/dev/null 2>&1
  then
    set -- "$SHELL -c 'col -bx | bat -l man --style=plain --paging=always'"
    # highlighting man page with bat
    export MANPAGER="$*"
  elif [ "$EDITOR" = 'vim' ]
  then
    set -- "$SHELL -c 'col -bx | vim -u NONE -NR -c \"se hls is nolist noma nomod sc scs wrap ft=man | syntax enable\" -'"
    # use vim
    export MANPAGER="$*"
  fi
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
