# is interactive? {{{
case "$-" in
  *i*)
    __interactive=1
    ;;
  *)
    __interactive=
    ;;
esac
# }}}

#-------------------------------------------------------------------------------

__main() {
  # which platform? {{{
  case "$OSTYPE" in
    darwin*)
      local __platform=osx
      ;;
    linux*)
      local __platform=linux
      ;;
  esac
  # }}}

  #-----------------------------------------------------------------------------

  # synchronize for Makefile
  local homebrew_dir=$HOME/Homebrew

  # homebrew / linuxbrew {{{
  local homebrew=$homebrew_dir
  local homebrew_infopath=$homebrew/share/info
  local homebrew_manpath=$homebrew/share/man
  local homebrew_path=$homebrew/bin
  export INFOPATH=$homebrew_infopath:${INFOPATH//$homebrew_infopath:/}
  export MANPATH=$homebrew_manpath:${MANPATH//$homebrew_manpath:/}
  export PATH=$homebrew_path:${PATH//$homebrew_path:/}

  local homebrew_prefix=$(brew --prefix)

  # for linuxbrew
  if [ "x$__platform" = 'xlinux' ]
  then
    # https://www.digitalocean.com/community/tutorials/how-to-install-and-use-linuxbrew-on-a-linux-vps
    export PKG_CONFIG_PATH=$homebrew/lib64/pkgconfig:$homebrew/lib/pkgconfig:$PKG_CONFIG_PATH
    export LD_LIBRARY_PATH=$homebrew/lib64:$homebrew/lib:$LD_LIBRARY_PATH
  fi
  # }}}

  # rbenv {{{
  local rbenv=$HOME/.rbenv/bin
  export PATH=$rbenv:${PATH//$rbenv:/}
  [ -n "$__interactive" ] &&
    type rbenv >/dev/null 2>&1 &&
    eval "$(rbenv init -)"
  # }}}

  # pyenv {{{
  local pyenv=$HOME/.pyenv/shims
  export PATH=$pyenv:${PATH//$pyenv:/}
  [ -n "$__interactive" ] &&
    type pyenv >/dev/null 2>&1 &&
    eval "$(pyenv init -)"
  # }}}

  # nodebrew {{{
  local nodebrew=$HOME/.nodebrew/current/bin
  export PATH=$nodebrew:${PATH//$nodebrew:/}
  # }}}

  # go {{{
  local go_gopath=$HOME/.go
  local go_gopath_bin=$go_gopath/bin
  export GOPATH=$go_gopath
  export PATH=$go_gopath_bin:${PATH//$go_gopath_bin:/}
  # }}}

  #-----------------------------------------------------------------------------

  # pgvm {{{
  local pgvm_home=$HOME/.pgvm
  local pgvm_home_bin=$pgvm_home/bin
  local pgvm_home_env=$pgvm_home/environments/current/bin
  [ -d "$pgvm_home" ] &&
    export pgvm_home &&
    export PATH=$pgvm_home:${PATH//$pgvm_home:/} &&
    export PATH=$pgvm_home_bin:${PATH//$pgvm_home_bin:/} &&
    export PATH=$pgvm_home_env:${PATH//$pgvm_home_env:/}
  # }}}

  # cocproxy for nginx {{{
  local cocproxy_dir=$HOME/.cocproxy
  local cocproxy_conf=$HOME/.cocproxy.nginx.conf
  [ -d "$cocproxy_dir" -a -f "$cocproxy_conf" ] &&
    alias cocproxy="(cd \"$cocproxy_dir\" && nginx -p . -c \"$cocproxy_conf\")"
  # }}}

  # vim {{{

  # macvim
  local macvim=/Applications/MacVim.app/Contents/MacOS
  [ -d "$macvim" ] &&
    export PATH=$macvim:${PATH//$macvim:/}
  [ -x "$macvim/Vim" ] &&
    alias vim="$macvim/Vim \"\$@\"" &&
    export EDITOR=vim

  # macvim from homebrew-cask
  local macvim=$HOME/Caskroom/macvim-kaoriya
  [ -d "$macvim" ] &&
    macvim=$macvim/$(ls $macvim)/MacVim.app/Contents/MacOS
  [ -d "$macvim" ] &&
    export PATH=$macvim:${PATH//$macvim:/}
  [ -x "$macvim/Vim" ] &&
    alias vim="$macvim/Vim \"\$@\"" &&
    export EDITOR=vim

  # compile from source
  local vim=$HOME/Binary/vim
  [ -d "$vim" ] &&
    local vim_manpath=$vim/share/man &&
    local vim_path=$vim/bin &&
    alias vim="$vim/bin/vim \"\$@\"" &&
    export MANPATH=$vim_manpath:${MANPATH//$vim_manpath:/} &&
    export PATH=$vim_path:${PATH//$vim_path:/} &&
    export EDITOR=vim

  # }}}

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  local ssh_agent=/usr/bin/ssh-agent
  local ssh_agent_info=$HOME/.ssh-agent-info

  source "$ssh_agent_info" 2>/dev/null

  ssh-add -l >/dev/null 2>&1

  if [ "$?" -eq 2 -a -x "$ssh_agent" -a -z "$SSH_AGENT_PID" ]
  then
    eval "$ssh_agent | grep -v 'echo' > $ssh_agent_info" 2>/dev/null
    source "$ssh_agent_info" 2>/dev/null
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # bash-completion {{{
  if [ -z "$BASH_COMPLETION" ]
  then
    case "$__platform" in
      osx)
        source "$homebrew_prefix/etc/bash_completion" 2>/dev/null
        ;;
      linux)
        source /etc/bash_completion 2>/dev/null
        ;;
    esac

    ###[ -r "$bash_completion" ] &&
    ###  BASH_COMPLETION=$bash_completion &&
    ###  BASH_COMPLETION_DIR=${bash_completion}.d &&
    ###  BASH_COMPLETION_COMPAT_DIR=$BASH_COMPLETION_DIR
    ###
    ###source "$BASH_COMPLETION" 2>/dev/null
  fi
  # }}}

  # nodebrew-completion
  source "$HOME/.nodebrew/completions/bash/nodebrew-completion" 2>/dev/null

  # npm-completion
  source "$HOME/.npm_completion" 2>/dev/null

  # bower-completion
  source "$HOME/.bower_completion" 2>/dev/null

  # up.sh
  source "$HOME/.ghq/github.com/sasaplus1/up.sh/up.sh" 2>/dev/null

  # down.sh
  export _DOWN_CMD=dw
  source "$HOME/.ghq/github.com/sasaplus1/down.sh/down.sh" 2>/dev/null

  # sandbox.sh
  export _SANDBOX_CMD=sb
  source "$HOME/.ghq/github.com/sasaplus1/sandbox.sh/sandbox.sh" 2>/dev/null

  # z {{{
  source "$homebrew_prefix/etc/profile.d/z.sh" 2>/dev/null
  if [ "$?" -eq 0 ]
  then
    precmd() {
      _z --add "$(pwd -P)"
    }
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # alias {{{
  case "$__platform" in
    osx)
      alias ls='ls -G'
      alias grep='grep --color=auto'
      alias sed_ere='sed -E'
      alias ios='open -a "Simulator" || open -a "iOS Simulator" || open -a "iPhone Simulator"'
      alias updatedb='LOCATE_CONFIG=$HOME/.locate.rc /usr/libexec/locate.updatedb'
      alias locate='locate -d "$HOME/.locate.database"'
      ;;
    linux)
      alias crontab='crontab -i'
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias sed_ere='sed -e'
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
      ;;
  esac

  if [ "$EDITOR" = 'vim' ]
  then
    alias vf='vim +VimFiler'
  fi

  alias memo='$EDITOR $(date +%FT%H-%M-%S).md'
  alias server='python -m SimpleHTTPServer'
  alias fake-dev='nginx -p . -c "$(ghq list -p fake-dev)/fake-dev.conf"'
  # }}}
}
__main

#-------------------------------------------------------------------------------

# pager
export PAGER=less

# fix typo of path for cd command
shopt -s cdspell

# stop flow mode (disable C-s)
stty stop undef

# PS1 {{{
__seq_red='\e[01;31m'
__seq_green='\e[01;32m'
__seq_yellow='\e[01;33m'
__seq_cyan='\e[01;36m'
__seq_reset='\e[00m'

__print_exit_code() {
  [ "$1" -ne 0 ] && printf " ${__seq_red}%s${__seq_reset}" "$1"
}

__print_repo_info() {
  local vcs=

  if [ -n "$(git branch -r --list 'git-svn' 2>/dev/null)" ]
  then
    vcs="$(vcprompt -f 'git-svn:%b:%r' 2>/dev/null)"
  else
    vcs="$(vcprompt -f '%n:%b:%r' 2>/dev/null)"
  fi

  # local config=

  # if [ -z "$(git config --local --get user.name)" -a -z "$(git config --local --get user.email)" ]
  # then
  #   config='user.name/user.email'
  # fi

  [ -n "$vcs" ] && printf " ${__seq_cyan}(%s)${__seq_reset} ${__seq_red}%s${__seq_reset}" "${vcs%:}" # "$config"
}

__print_run_in_vim() {
  [ -n "$VIM" ] && printf "${__seq_cyan}(vim)${__seq_reset} "
}

# /current/dir err (vcs:branch:rev)
# username@hostname$ _
export PS1=$(
  printf "${__seq_green}%s${__seq_reset}" '\w'
  printf '$(__print_exit_code $?)'
  printf '$(__print_repo_info)'
  printf '\n'
  printf '$(__print_run_in_vim)\u@\h\$ '
)
# }}}

# history {{{
if [ "$SHLVL" -eq 1 ]
then
  export HISTSIZE=10000
  export HISTFILESIZE=10000
  export HISTTIMEFORMAT='%Y/%m/%d %T '
  export HISTCONTROL=ignoredups:erasedups
fi

###share_history() {
###  history -a
###  history -c
###  history -r
###}
###shopt -s histappend
###export PROMPT_COMMAND='share_history'
# }}}

# functions {{{

# change to urxvt font size
# from https://gist.github.com/anekos/5938365
if type urxvt >/dev/null 2>&1
then
  set-urxvt-font-size() {
    local old_name=$(grep -i '^\s*urxvt.font' "$HOME/.Xdefaults" | cut -d: -f2-)
    local new_name=$(printf "$old_name" | sed -e 's/:\(pixel\)\?size=[0-9]\+/'":\1size=$1/")

    [ -n "$TMUX" ] && printf '\ePtmux;\e'
    printf '\e]50;%s\007' "$new_name"
    [ -n "$TMUX" ] && printf '\e\\'
  }
fi

# find file
ff() {
  [ -n "$1" ] && find "$(pwd)" $(< $HOME/.findrc) -type f -iname $1 -print
}

# find directory
fd() {
  [ -n "$1" ] && find "$(pwd)" $(< $HOME/.findrc) -type d -iname $1 -print
}

# incremental search and change directory
ccd() {
  cd "$(
    cat \
      <(ghq list -p) \
      <(z -l | awk '{ print $2 }') \
      <(mdfind -onlyin "$(pwd)" "kMDItemContentType == public.folder" 2>/dev/null) |
    peco --select-1 --query="$*"
  )"
}

# incremental search and kill process
kkill() {
  local pid=$(ps xo pid,user,uid,command | sed -e 1d | peco --select-1 --query="$*" | awk '{ print $1 }')
  [ -n "$pid" ] && kill -9 "$pid"
}

# remove docker containers
d-rm() {
  docker ps -a | sed 1d | peco | awk '{ print $1 }' | xargs docker rm
}

# remove docker images
d-rmi() {
  docker images | sed 1d | peco | awk '{ print $3 }' | xargs docker rmi
}

# execute command in container
d-sh() {
  docker exec -it $(docker ps | sed 1d | peco | awk '{ print $1 }' | sed -n 1p) $1
}

# }}}

# load .bashrc.local
source "$HOME/.bashrc.local" 2>/dev/null

# proxy settings {{{
# export ftp_proxy=ftp://proxy:port
# export FTP_PROXY=$ftp_proxy

# export http_proxy=http://proxy:port
# export HTTP_PROXY=$http_proxy

# export https_proxy=https://proxy:port
# export HTTPS_PROXY=$https_proxy

# export no_proxy=127.0.0.1,localhost
# export NO_PROXY=$no_proxy
# }}}

# always use terminal multiplexer {{{
if [ -n "$__interactive" -a -z "$VIM" ] && [[ ! "$TERM" =~ screen|dumb ]]
then
  tmux attach || screen -rx || tmux || screen -D -RR
fi
# }}}

# vim:ft=sh:fdm=marker:fen:
