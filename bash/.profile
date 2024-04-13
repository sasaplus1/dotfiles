#!/bin/sh
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  [ -n "$__SOURCED_PROFILE" ] && return
  export __SOURCED_PROFILE=1
  readonly __SOURCED_PROFILE

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

  # NOTE: In POSIX sh, 'local' is undefined: SC3043

  #-----------------------------------------------------------------------------

  # NOTE: In POSIX sh, $OSTYPE is undefined: SC3028
  case "$(uname | tr '[:upper:]' '[:lower:]')" in
    darwin*)
      __main_os=macos
      ;;
    linux*)
      __main_os=linux
      ;;
    *)
      __main_os=
      ;;
  esac

  #-----------------------------------------------------------------------------

  # Homebrew {{{
  __main_homebrew_prefix=

  if [ "$__main_os" = 'macos' ]
  then
    [ -d '/usr/local/Homebrew' ] && __main_homebrew_prefix=/usr/local
    # NOTE: my original location
    [ -d "$HOME/Homebrew" ] && __main_homebrew_prefix=$HOME/Homebrew
  fi

  if [ "$__main_os" = 'linux' ]
  then
    [ -d '/home/linuxbrew/.linuxbrew/Homebrew' ] &&
      __main_homebrew_prefix=/home/linuxbrew/.linuxbrew
    [ -d "$HOME/.linuxbrew/Homebrew" ] &&
      __main_homebrew_prefix=$HOME/.linuxbrew
  fi

  if [ -d "$__main_homebrew_prefix" ]
  then
    export INFOPATH="$__main_homebrew_prefix/share/info:$INFOPATH"
    export MANPATH="$__main_homebrew_prefix/share/man:$MANPATH"
    export PATH="$__main_homebrew_prefix/bin:$PATH"

    # NOTE: In POSIX sh, type -t is undefined: SC3045
    # NOTE: brew --prefix is very slow https://github.com/Homebrew/brew/issues/3097
    [ -d "$(dirname "$(dirname "$(command -v brew)")")" ] &&
      export HOMEBREW_PREFIX="$__main_homebrew_prefix"
  fi
  # }}}

  # MacPorts {{{
  __main_macports_prefix=/opt/local

  if [ "$__main_os" = 'macos' ] && [ -d "$__main_macports_prefix" ]
  then
    export INFOPATH="$__main_macports_prefix/share/info:$INFOPATH"
    export MANPATH="$__main_macports_prefix/share/man:$MANPATH"
    export PATH="$__main_macports_prefix/sbin:$PATH"
    export PATH="$__main_macports_prefix/bin:$PATH"
  fi
  # }}}

  # .local {{{
  __main_dotlocal_prefix="$HOME/.local"

  if [ -d "$__main_dotlocal_prefix" ]
  then
    export PATH="$__main_dotlocal_prefix/bin:$PATH"
  fi
  # }}}

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

    eval "$(command ssh-agent | grep -v 'echo' >"$__main_ssh_agent_info")" 2>/dev/null
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # ghq {{{
  export GHQ_ROOT="$HOME/.ghq"
  # }}}

  # mise {{{
  [ -d "$HOME/.local/share/mise" ] && export PATH="$HOME/.local/share/mise/shims:$PATH"
  # }}}

  # nvm {{{
  if [ -z "${XDG_CONFIG_HOME-}" ]
  then
    export NVM_DIR="$HOME/.nvm"
  else
    export NVM_DIR="$XDG_CONFIG_HOME/nvm"
  fi
  # }}}

  # rbenv {{{
  [ -d "$HOME/.rbenv" ] && export PATH="$HOME/.rbenv/bin:$PATH"
  # }}}

  # gibo {{{
  __main_gibo="$GHQ_ROOT/github.com/simonwhitaker/gibo"
  [ -s "$__main_gibo/gibo" ] && export PATH="$__main_gibo:$PATH"
  # }}}

  # go {{{
  __main_go_gopath="$HOME/.go"
  __main_go_gopath_bin="$__main_go_gopath/bin"
  export GOPATH="$__main_go_gopath"
  export PATH="$__main_go_gopath_bin:$PATH"
  # }}}

  # adb/android-platform-tools {{{
  __main_android_platform_tools="$HOME/Library/Android/sdk/platform-tools"
  [ -d "$__main_android_platform_tools" ] && export PATH="$__main_android_platform_tools:$PATH"
  # }}}

  # wezterm {{{
  [ "$__main_os" = 'macos' ] && __main_wezterm="/Applications/WezTerm.app/Contents/MacOS"
  [ -d "$__main_wezterm" ] && export PATH="$__main_wezterm:$PATH"
  # }}}

  # vim {{{
  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/macos-vim
  __main_mvim="$GHQ_ROOT/github.com/sasaplus1/macos-vim"
  [ -x "$__main_mvim/usr/bin/vim" ] &&
    export MANPATH="$__main_mvim/share/man:$MANPATH" &&
    export PATH="$__main_mvim/usr/bin:$PATH"
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
    # highlighting man page with bat
    export MANPAGER="$SHELL -c 'col -bx | bat -l man --style=plain --paging=always'"
  elif [ "$EDITOR" = 'vim' ]
  then
    # use vim
    export MANPAGER="$SHELL -c 'col -bx | vim -u NONE -NR -c \"se hls is nolist noma nomod sc scs wrap ft=man | syntax enable\" -'"
  fi
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
