#!/bin/sh
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  [ -n "$__SOURCED_PROFILE" ] && return
  export readonly __SOURCED_PROFILE=1

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
      export HOMEBREW_PREFIX=$__main_homebrew_prefix
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

  export GHQ_ROOT=$HOME/.ghq

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  __main_ssh_agent="$(command -v ssh-agent)"
  __main_ssh_agent_info="$HOME/.ssh-agent-info"

  # In POSIX sh, 'source' in place of '.' is undefined: SC3046
  # shellcheck disable=SC1090
  . "$__main_ssh_agent_info" 2>/dev/null

  ssh-add -l >/dev/null 2>&1

  if [ "$?" -eq 2 ] && [ -x "$__main_ssh_agent" ] && [ -z "$SSH_AGENT_PID" ]
  then
    eval "$__main_ssh_agent | grep -v 'echo' > $__main_ssh_agent_info" 2>/dev/null
    # shellcheck disable=SC1090
    . "$__main_ssh_agent_info" 2>/dev/null
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # nvm {{{
  if [ -z "${XDG_CONFIG_HOME-}" ]
  then
    export NVM_DIR="$HOME/.nvm"
  else
    export NVM_DIR="$XDG_CONFIG_HOME/nvm"
  fi
  # }}}

  # nodebrew {{{
  [ -d "$HOME/.nodebrew" ] && export PATH="$HOME/.nodebrew/current/bin:$PATH"
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

  # vim {{{
  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/portable-vim
  __main_pvim="$HOME/Binary/vim"
  [ -d "$__main_pvim" ] &&
    export MANPATH="$__main_pvim/share/man:$MANPATH" &&
    export PATH="$__main_pvim/bin:$PATH"

  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/macos-vim
  __main_mvim="$GHQ_ROOT/github.com/sasaplus1/macos-vim"
  [ -x "$__main_mvim/usr/bin/vim" ] &&
    export MANPATH="$__main_mvim/share/man:$MANPATH" &&
    export PATH="$__main_mvim/usr/bin:$PATH"
  # }}}
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
