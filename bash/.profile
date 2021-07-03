#!/bin/sh
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  #-----------------------------------------------------------------------------

  # add $2 to $1 if not duplicate
  # @param $1 variable name
  # @param $2 path string
  # @example add-path PATH /opt/local/bin
  # @see https://unix.stackexchange.com/a/14898
  # BUG: why add $2 at the suffix? :(
  add-path() {
    # NOTE: https://stackoverflow.com/a/14050187
    case ":${!1}:" in
      *":$2:"*)
        :
        ;;
      *)
        export "$1"="$2":"${!1}"
        ;;
    esac
  }

  #-----------------------------------------------------------------------------

  case "$OSTYPE" in
    darwin*)
      local -r os=macos
      ;;
    linux*)
      local -r os=linux
      ;;
    *)
      local -r os=
      ;;
  esac

  #-----------------------------------------------------------------------------

  # Homebrew {{{
  local homebrew_prefix=

  if [ "$os" == 'macos' ]
  then
    [ -d '/usr/local/Homebrew' ] && homebrew_prefix=/usr/local
    # NOTE: my original location
    [ -d "$HOME/Homebrew" ] && homebrew_prefix=$HOME/Homebrew
  fi

  if [ "$os" == 'linux' ]
  then
    [ -d '/home/linuxbrew/.linuxbrew/Homebrew' ] &&
      homebrew_prefix=/home/linuxbrew/.linuxbrew
    [ -d "$HOME/.linuxbrew/Homebrew" ] &&
      homebrew_prefix=$HOME/.linuxbrew
  fi

  if [ -d "$homebrew_prefix" ]
  then
    local -r homebrew_infopath=$homebrew_prefix/share/info
    local -r homebrew_manpath=$homebrew_prefix/share/man
    local -r homebrew_path=$homebrew_prefix/bin

    # add-path INFOPATH "$homebrew_infopath"
    # add-path MANPATH "$homebrew_manpath"
    # add-path PATH "$homebrew_path"
    export INFOPATH="$homebrew_infopath:$INFOPATH"
    export MANPATH="$homebrew_manpath:$MANPATH"
    export PATH="$homebrew_path:$PATH"

    # NOTE: brew --prefix is very slow https://github.com/Homebrew/brew/issues/3097
    [ -d "$(dirname "$(dirname "$(type -tP brew)")")" ] &&
      export HOMEBREW_PREFIX=$homebrew_prefix
  fi
  # }}}

  # MacPorts {{{
  local -r macports_prefix=/opt/local

  if [ "$os" == 'macos' ] && [ -d "$macports_prefix" ]
  then
    # add-path INFOPATH "$macports_prefix/share/info"
    # add-path MANPATH "$macports_prefix/share/man"
    # add-path PATH "$macports_prefix/sbin"
    # add-path PATH "$macports_prefix/bin"
    export INFOPATH="$macports_prefix/share/info:$INFOPATH"
    export MANPATH="$macports_prefix/share/man:$MANPATH"
    export PATH="$macports_prefix/sbin:$PATH"
    export PATH="$macports_prefix/bin:$PATH"
  fi
  # }}}

  # .local {{{
  local -r dotlocal_prefix="$HOME/.local"

  if [ -d "$dotlocal_prefix" ]
  then
    # add-path PATH "$dotlocal_prefix/bin"
    export PATH="$dotlocal_prefix/bin:$PATH"
  fi
  # }}}

  #-----------------------------------------------------------------------------

  export GHQ_ROOT=$HOME/.ghq

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  local -r ssh_agent="$(type -tP ssh-agent)"
  local -r ssh_agent_info="$HOME/.ssh-agent-info"

  # shellcheck disable=SC1090
  source "$ssh_agent_info" 2>/dev/null

  ssh-add -l >/dev/null 2>&1

  if [ "$?" -eq 2 ] && [ -x "$ssh_agent" ] && [ -z "$SSH_AGENT_PID" ]
  then
    eval "$ssh_agent | grep -v 'echo' > $ssh_agent_info" 2>/dev/null
    # shellcheck disable=SC1090
    source "$ssh_agent_info" 2>/dev/null
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
  # [ -d "$HOME/.nodebrew" ] && add-path PATH "$HOME/.nodebrew/current/bin"
  [ -d "$HOME/.nodebrew" ] && export PATH="$HOME/.nodebrew/current/bin:$PATH"
  # }}}

  # gibo {{{
  local -r gibo="$GHQ_ROOT/github.com/simonwhitaker/gibo"
  # [ -s "$gibo/gibo" ] && add-path PATH "$gibo"
  [ -s "$gibo/gibo" ] && export PATH="$gibo:$PATH"
  # }}}

  # go {{{
  local -r go_gopath="$HOME/.go"
  local -r go_gopath_bin="$go_gopath/bin"
  export GOPATH="$go_gopath"
  # add-path PATH "$go_gopath_bin"
  export PATH="$go_gopath_bin:$PATH"
  # }}}

  # adb/android-platform-tools {{{
  local -r android_platform_tools="$HOME/Library/Android/sdk/platform-tools"
  # [ -d "$android_platform_tools" ] && add-path PATH "$android_platform_tools"
  [ -d "$android_platform_tools" ] && export PATH="$android_platform_tools:$PATH"
  # }}}

  # vim {{{
  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/portable-vim
  local -r pvim="$HOME/Binary/vim"
  [ -d "$pvim" ] &&
    local -r pvim_manpath="$pvim/share/man" &&
    local -r pvim_path="$pvim/bin" &&
    # add-path MANPATH "$pvim_manpath" &&
    # add-path PATH "$pvim_path"
    export MANPATH="$pvim_manpath:$MANPATH" &&
    export PATH="$pvim_path:$PATH"

  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/macos-vim
  local -r mvim="$GHQ_ROOT/github.com/sasaplus1/macos-vim"
  [ -x "$mvim/usr/bin/vim" ] &&
    local -r mvim_manpath=$mvim/share/man &&
    local -r mvim_path=$mvim/usr/bin &&
    # add-path MANPATH "$mvim_manpath" &&
    # add-path PATH "$mvim_path"
    export MANPATH="$mvim_manpath:$MANPATH" &&
    export PATH="$mvim_path:$PATH"
  # }}}
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
