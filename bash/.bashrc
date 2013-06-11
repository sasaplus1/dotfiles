# load .bashrc.first
source "$HOME/.bashrc.first" 2>/dev/null



# bash-completion for OS X or Ubuntu
if [ -z "$BASH_COMPLETION" ]
then
  if [ -r "$HOME/Binary/bash-completion/etc/bash_completion" ]
  then
    bash_completion=$HOME/Binary/bash-completion/etc/bash_completion
  elif [ -r "/etc/bash_completion" ]
  then
    bash_completion=/etc/bash_completion
  fi

  [ -r "$bash_completion" ] &&
    BASH_COMPLETION=$bash_completion &&
    BASH_COMPLETION_DIR=${bash_completion}.d &&
    BASH_COMPLETION_COMPAT_DIR=$BASH_COMPLETION_DIR

  # bash-completion
  source "$BASH_COMPLETION" 2>/dev/null
fi

# ctags
ctags=$HOME/Binary/ctags
[ -d "$ctags" ] &&
  ctags_manpath=$ctags/share/man &&
  ctags_path=$ctags/bin &&
  export MANPATH=$ctags_manpath:${MANPATH//$ctags_manpath:/} &&
  export PATH=$ctags_path:${PATH//$ctags_path:/}

# git
git=/usr/local/git
[ -d "$git" ] &&
  git_manpath=$git/share/man &&
  git_path=$git/bin &&
  export MANPATH=$git_manpath:${MANPATH//$git_manpath:/} &&
  export PATH=$git_path:${PATH//$git_path:/}

# git-completion
source "$git/contrib/completion/git-completion.bash" 2>/dev/null

# heroku
heroku=/usr/local/heroku
[ -d "$heroku" ] &&
  heroku_path=$heroku/bin &&
  export PATH=$heroku_path:${PATH//$heroku_path:/}

# tig
tig=$HOME/Binary/tig
[ -d "$tig" ] &&
  tig_manpath=$tig/share/man &&
  tig_path=$tig/bin &&
  export MANPATH=$tig_manpath:${MANPATH//$tig_manpath:/} &&
  export PATH=$tig_path:${PATH//$tig_path:/}

# vcprompt
vcprompt=$HOME/Binary/vcprompt
[ -d "$vcprompt" ] &&
  vcprompt_path=$vcprompt/bin &&
  export PATH=$vcprompt_path:${PATH//$vcprompt_path:/}

# z
z=$HOME/Binary/z
[ -d "$z" ] &&
  export PATH=$z:${PATH//$z:/}
touch $HOME/.z
source $z/z.sh 2>/dev/null
precmd() {
  _z --add "$(pwd -P)"
}



# go
go=$HOME/Binary/go
[ -d "$go" ] &&
  go_path=$go/bin &&
  go_gopath=$HOME/.go &&
  go_gopath_bin=$go_gopath/bin &&
  export GOROOT=$go &&
  export GOPATH=$go_gopath &&
  export PATH=$go_path:${PATH//$go_path:/} &&
  export PATH=$go_gopath_bin:${PATH//$go_gopath_bin:/}

# nodebrew
nodebrew=$HOME/.nodebrew/current/bin
[ -d "$nodebrew" ] &&
  export PATH=$nodebrew:${PATH//$nodebrew:/}

# npm-completion
source "$HOME/.npm_completion" 2>/dev/null

# bower-completion
source "$HOME/.bower_completion" 2>/dev/null

# rbenv
rbenv=$HOME/.rbenv/bin
[ -d "$rbenv" ] &&
  export PATH=$rbenv:${PATH//$rbenv:/}
type rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# pgvm
pgvm_home=$HOME/.pgvm
pgvm_home_bin=$pgvm_home/bin
pgvm_home_env=$pgvm_home/environments/current/bin
[ -d "$pgvm_home" ] &&
  export pgvm_home &&
  export PATH=$pgvm_home:${PATH//$pgvm_home:/} &&
  export PATH=$pgvm_home_bin:${PATH//$pgvm_home_bin:/} &&
  export PATH=$pgvm_home_env:${PATH//$pgvm_home_env:/}



# vim
vim=$HOME/Binary/vim
[ -d "$vim" ] &&
  vim_manpath=$vim/share/man &&
  vim_path=$vim/bin &&
  export MANPATH=$vim_manpath:${MANPATH//$vim_manpath:/} &&
  export PATH=$vim_path:${PATH//$vim_path:/} &&
  export EDITOR=vim

# MacVim
macvim=/Applications/MacVim.app/Contents/MacOS
[ -d "$macvim" ] &&
  export PATH=$macvim:${PATH//$macvim:/}
[ -x "$macvim/Vim" ] &&
  alias vim="$macvim/Vim \"\$@\""


# screen
screen=$HOME/Binary/screen
[ -d "$screen" ] &&
  screen_manpath=$screen/share/man &&
  screen_path=$screen/bin &&
  export MANPATH=$screen_manpath:${MANPATH//$screen_manpath:/} &&
  export PATH=$screen_path:${PATH//$screen_path:/}

# tmux-MacOSX-pasteboard
tmux_macosx_pasteboard=$HOME/Binary/tmux-MacOSX-pasteboard
[ -d "$tmux_macosx_pasteboard" ] &&
  export PATH=$tmux_macosx_pasteboard:${PATH//$tmux_macosx_pasteboard:/}

# tmux and libevent
tmux=$HOME/Binary/tmux
libevent=$HOME/Binary/libevent
[ -d "$tmux" -a -d "$libevent" ] &&
  tmux_manpath=$tmux/share/man &&
  tmux_path=$tmux/bin &&
  export MANPATH=$tmux_manpath:${MANPATH//$tmux_manpath:/} &&
  export PATH=$tmux_path:${PATH//$tmux_path:/}

# tmux
type tmux >/dev/null 2>&1 &&
  alias tmux="LD_LIBRARY_PATH=$libevent/lib tmux"





# ssh-agent {{{
ssh_agent=/usr/bin/ssh-agent
ssh_agent_info=$HOME/.ssh-agent-info

source "$ssh_agent_info" 2>/dev/null

ssh-add -l >/dev/null 2>&1

if [ "$?" -eq 2 -a -x "$ssh_agent" -a -z "$SSH_AGENT_PID" ]
then
  eval "$ssh_agent | grep -v 'echo' > $ssh_agent_info" 2>/dev/null
  source "$ssh_agent_info" 2>/dev/null
fi
# }}}

# alias {{{
case "$(uname)" in
  Darwin)
    alias ls='ls -G'
  ;;
  Linux)
    alias crontab='crontab -i'
    alias ls='ls --color=auto'
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  ;;
esac # }}}

# history {{{
[ -z "$LOADED_BASHRC" ] && export HISTSIZE=10000
[ -z "$LOADED_BASHRC" ] && export HISTTIMEFORMAT='%Y/%m/%d %T '

#share_history() {
#  history -a
#  history -c
#  history -r
#}
#shopt -u histappend
#PROMPT_COMMAND='share_history'
# }}}

# stop flow mode (disable C-s)
stty stop undef

# print repository type and branch name of current dir
print_repos_info() {
  type vcprompt >/dev/null 2>&1 && vcprompt -f '(%n:%b)'
}

# /current/dir (hg/git/svn:branch)
# username@hostname$ _
export PS1=\
'\[\033[01;32m\]\w\[\033[00m\] '\
'\[\033[01;36m\]$(print_repos_info)\[\033[00m\]\n'\
'\u@\h\$ '



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

# set load guard
export LOADED_BASHRC=1

# always use terminal multiplexer {{{
if [ "$TERM" != 'screen' -a "$TERM" != 'dumb' ]
then
  if type tmux >/dev/null 2>&1
  then
    tmux attach || tmux
  elif type screen >/dev/null 2>&1
  then
    screen -rx || screen -D -RR
  fi
fi # }}}

# vim:ft=sh:fdm=marker:fen:
