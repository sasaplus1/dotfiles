#!/bin/sh
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  # NOTE: In POSIX sh, 'local' is undefined: SC3043

  [ -n "$__PROFILE_SOURCED" ] && return
  export __PROFILE_SOURCED=1
  readonly __PROFILE_SOURCED

  __profile_sh_path="$HOME/.sh_path"
  # In POSIX sh, 'source' in place of '.' is undefined: SC3046
  # shellcheck disable=SC1090
  [ -r "$__profile_sh_path" ] && . "$__profile_sh_path"

  #-----------------------------------------------------------------------------

  # history settings
  export HISTSIZE=10000
  export HISTFILESIZE=10000
  export HISTTIMEFORMAT='%Y/%m/%d %T '
  export HISTCONTROL=ignoredups:erasedups

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  __profile_ssh_agent_info="$HOME/.ssh-agent-info"

  # In POSIX sh, 'source' in place of '.' is undefined: SC3046
  # shellcheck disable=SC1090
  [ -r "$__profile_ssh_agent_info" ] && . "$__profile_ssh_agent_info"

  command ssh-add -l >/dev/null 2>&1
  __ssh_add_status=$?

  # ssh-add is unable to contact the authentication agent
  if [ "$__ssh_add_status" -eq 2 ]
  then
    # force remove
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    rm -f "$__profile_ssh_agent_info"

    if command -v ssh-agent >/dev/null 2>&1
    then
      eval "$(command ssh-agent | grep -v 'echo')"
      {
        printf 'SSH_AUTH_SOCK=%s; export SSH_AUTH_SOCK;\n' "$SSH_AUTH_SOCK"
        printf 'SSH_AGENT_PID=%s; export SSH_AGENT_PID;\n' "$SSH_AGENT_PID"
      } > "$__profile_ssh_agent_info"
    fi
  fi

  unset __ssh_add_status
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
