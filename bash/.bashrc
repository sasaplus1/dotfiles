__main() {
  local os=

  case "$OSTYPE" in
    darwin*) os=macos ;;
    linux*)  os=linux ;;
    *)       os=      ;;
  esac

  #-----------------------------------------------------------------------------

  local homebrew_dir=$HOME/Homebrew
  local homebrew_infopath=$homebrew_dir/share/info
  local homebrew_manpath=$homebrew_dir/share/man
  local homebrew_path=$homebrew_dir/bin

  export INFOPATH=$homebrew_infopath:${INFOPATH//$homebrew_infopath/}
  export MANPATH=$homebrew_manpath:${MANPATH//$homebrew_manpath/}
  export PATH=$homebrew_path:${PATH//$homebrew_path/}

  local homebrew_prefix=

  # NOTE: brew --prefix is very slow https://github.com/Homebrew/brew/issues/3097
  homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"

  # for linuxbrew
  if [ "$os" = 'linux' ]
  then
    # NOTE: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-linuxbrew-on-a-linux-vps
    export PKG_CONFIG_PATH=$homebrew_dir/lib64/pkgconfig:$homebrew_dir/lib/pkgconfig:$PKG_CONFIG_PATH
    export LD_LIBRARY_PATH=$homebrew_dir/lib64:$homebrew_dir/lib:$LD_LIBRARY_PATH
  fi

  # NOTE: lazy load command https://qiita.com/uasi/items/80865646607b966aedc8
  # NOTE: lazy load completion https://qiita.com/kawaz/items/ba6140bca32bbd3cb928

  # rbenv {{{
  local rbenv=$HOME/.rbenv/bin
  export PATH=$rbenv:${PATH//$rbenv/}

  # lazy loading
  rbenv() {
    unset -f rbenv
    eval "$(rbenv init -)"
    rbenv "$@"
  }

  # rbenv-completion
  __rbenv_completion() {
    unset -f __rbenv_completion
    complete -r rbenv
    local homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"
    source "$homebrew_prefix/opt/rbenv/completions/rbenv.bash" 2>/dev/null && return 124
  }
  complete -F __rbenv_completion rbenv
  # }}}

  # pyenv {{{
  local pyenv=$HOME/.pyenv/shims
  export PATH=$pyenv:${PATH//$pyenv/}

  # lazy loading
  pyenv() {
    unset -f pyenv
    eval "$(pyenv init -)"
    pyenv "$@"
  }

  # pyenv-completion
  __pyenv_completion() {
    unset -f __pyenv_completion
    complete -r pyenv
    local homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"
    source "$homebrew_prefix/opt/pyenv/completions/pyenv.bash" 2>/dev/null && return 124
  }
  complete -F __pyenv_completion pyenv
  # }}}

  # nodebrew and npm completion {{{
  local nodebrew=$HOME/.nodebrew/current/bin
  export PATH=$nodebrew:${PATH//$nodebrew/}

  # nodebrew-completion
  __nodebrew_completion() {
    unset -f __nodebrew_completion
    complete -r nodebrew
    source "$HOME/.nodebrew/completions/bash/nodebrew-completion" 2>/dev/null && return 124
  }
  complete -F __nodebrew_completion nodebrew

  # npm-completion
  __npm_completion() {
    unset -f __npm_completion
    complete -r npm
    eval "$(npm completion)" && return 124
  }
  complete -F __npm_completion npm
  # }}}

  # z {{{
  # lazy loading
  z() {
    unset -f z
    local homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"
    source "$homebrew_prefix/opt/z/etc/profile.d/z.sh" 2>/dev/null
    # NOTE: call _z function directly, because z is alias
    _z "$@"
  }

  # z-completion
  __z_completion() {
    unset -f __z_completion
    complete -r z
    local homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"
    source "$homebrew_prefix/opt/z/etc/profile.d/z.sh" 2>/dev/null && return 124
  }
  complete -F __z_completion z
  # }}}

  # go {{{
  local go_gopath=$HOME/.go
  local go_gopath_bin=$go_gopath/bin
  export GOPATH=$go_gopath
  export PATH=$go_gopath_bin:${PATH//$go_gopath_bin/}
  # }}}

  # adb/android-platform-tools {{{
  local android_platform_tools=$HOME/Library/Android/sdk/platform-tools
  export PATH=$android_platform_tools:${PATH//$android_platform_tools/}
  # }}}

  # cocproxy for nginx {{{
  cocproxy() {
    (cd "$HOME/.cocproxy" && nginx -p . -c "$HOME/.cocproxy.nginx.conf")
  }
  # }}}

  # vim {{{

  # macvim
  local macvim=/Applications/MacVim.app/Contents/MacOS
  [ -d "$macvim" ] &&
    export PATH=$macvim:${PATH//$macvim/} &&
    alias vim="$macvim/Vim \"\$@\"" &&
    export EDITOR="$macvim/Vim"

  # macvim from homebrew-cask
  # local macvim=$HOME/Caskroom/macvim-kaoriya/$(ls $HOME/Caskroom/macvim-kaoriya 2>/dev/null)/MacVim.app/Contents/MacOS
  # [ -d "$macvim" ] &&
  #   export PATH=$macvim:${PATH//$macvim/} &&
  #   alias vim="$macvim/Vim \"\$@\"" &&
  #   export EDITOR="$macvim/Vim"

  # my kaoriya-vim
  # via https://github.com/sasaplus1/vim
  local vim=$HOME/Binary/vim
  [ -d "$vim" ] &&
    local vim_manpath=$vim/share/man &&
    local vim_path=$vim/bin &&
    alias vim="$vim/bin/pvim \"\$@\"" &&
    export MANPATH=$vim_manpath:${MANPATH//$vim_manpath/} &&
    export PATH=$vim_path:${PATH//$vim_path/} &&
    export EDITOR="$vim/bin/pvim"
  # }}}

  # universal-ctags {{{
  local ctags=$homebrew_prefix/opt/universal-ctags
  [ -d "$ctags" ] &&
    local ctags_manpath=$ctags/share/man &&
    local ctags_path=$ctags/bin &&
    export MANPATH=$ctags_manpath:${MANPATH//$ctags_manpath/} &&
    export PATH=$ctags_path:${PATH//$ctags_path/}
  # }}}

  #-----------------------------------------------------------------------------

  export INFOPATH=${INFOPATH/%::*/}
  export MANPATH=${MANPATH/%::*/}
  export PATH=${PATH/%::*/}

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  local ssh_agent=/usr/bin/ssh-agent
  local ssh_agent_info=$HOME/.ssh-agent-info

  source "$ssh_agent_info" 2>/dev/null

  ssh-add -l >/dev/null 2>&1

  if [ "$?" -eq 2 ] && [ -x "$ssh_agent" ] && [ -z "$SSH_AGENT_PID" ]
  then
    eval "$ssh_agent | grep -v 'echo' > $ssh_agent_info" 2>/dev/null
    source "$ssh_agent_info" 2>/dev/null
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # bash-completion {{{
  if [ -z "$BASH_COMPLETION" ]
  then
    case "$os" in
      macos) source "$homebrew_prefix/etc/bash_completion" 2>/dev/null ;;
      linux) source /etc/bash_completion 2>/dev/null ;;
    esac
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # up.sh {{{
  up() {
    unset -f up
    source "$HOME/.ghq/github.com/shannonmoeller/up/up.sh" 2>/dev/null ||
    source "$HOME/.ghq/github.com/sasaplus1/up.sh/up.sh" 2>/dev/null
    up "$@"
  }
  # }}}

  # down.sh {{{
  export _DOWN_CMD=dw
  dw() {
    unset -f dw
    source "$HOME/.ghq/github.com/sasaplus1/down.sh/down.sh" 2>/dev/null
    dw "$@"
  }
  # }}}

  # github-slug.sh {{{
  export _GITHUB_SLUG_COMMAND=slug
  __lazy-github-slug() {
    unset -f __lazy-github-slug
    source "$HOME/.ghq/github.com/sasaplus1/github-slug.sh/github-slug.sh" 2>/dev/null
    __github-slug "$@"
    eval "$_GITHUB_SLUG_COMMAND"'() { __github-slug "$@"; }'
  }
  eval "$_GITHUB_SLUG_COMMAND"'() { __lazy-github-slug "$@"; }'
  # }}}

  #-----------------------------------------------------------------------------

  # functions and aliases {{{
  memo() {
    "$EDITOR" "$(date +%FT%H-%M-%S).md"
  }

  server() {
    python -m SimpleHTTPServer
  }

  fake-dev() {
    nginx -p . -c "$(ghq list -p fake-dev)/fake-dev.conf"
  }

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
    docker images | sed 1d | peco | awk '{ print $3 }' | xargs docker rmi --force
  }

  # execute command in container
  d-sh() {
    docker exec -it $(docker ps | sed 1d | peco | awk '{ print $1 }' | sed -n 1p) ${1:-sh}
  }

  case "$os" in
    macos)
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
    *)
      alias ctags='ctags --exclude=@$HOME/.ctagsignore'
      ;;
  esac
  # }}}

  #-----------------------------------------------------------------------------

  # pager
  export PAGER=less

  # fix typo of path for cd command
  shopt -s cdspell

  # stop flow mode (disable C-s)
  stty stop undef

  if [ "$SHLVL" -eq 1 ]
  then
    export HISTSIZE=10000
    export HISTFILESIZE=10000
    export HISTTIMEFORMAT='%Y/%m/%d %T '
    export HISTCONTROL=ignoredups:erasedups
  fi

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

  #-----------------------------------------------------------------------------

  # PS1 {{{
  __print_status() {
    local -r exit_code=$1

    local -r cyan='\e[01;36m'
    local -r green='\e[01;32m'
    local -r red='\e[01;31m'
    local -r reset='\e[00m'
    local -r yellow='\e[01;33m'

    local cwd="$PWD"

    # git refs
    local refs=

    # flags
    local is_git=
    local is_hash=
    local is_yarn=
    local is_lerna=

    # HEAD dir and file
    local head_dir=
    local head_file=

    # git or git-submodule or git-worktree
    local repo_type=

    while [ "$cwd" != '/' ]
    do
      # yarn
      # $ git ls-files ':(top)yarn.lock'
      # is too slow
      [ -f "${cwd}/yarn.lock" ] && is_yarn=1

      # lerna
      # $ git ls-files ':(top)lerna.json'
      # is too slow
      [ -f "${cwd}/lerna.json" ] && is_lerna=1

      # git-worktree or git-submodule
      # maybe read is faster than awk
      # https://qiita.com/hasegit/items/5be056d67347e1553f08
      if [ -f "${cwd}/.git" ]
      then
        read noop head_dir < "${cwd}/.git"
        head_file="${head_dir}/HEAD"

        [[ "$head_file" =~ \.git\/worktrees ]] &&
          repo_type=git-worktree ||
          repo_type=git-submodule
      fi

      # vcs info
      # $ vcprompt -f '%n:%b:%r' 2>/dev/null
      # is too slow
      if [ -d "${cwd}/.git" ]
      then
        local col1
        local col2

        is_git=1

        [ -z "$repo_type" ] && repo_type=git
        [ -z "$head_file" ] && head_file="${cwd}/.git/HEAD"

        read col1 col2 < "$head_file"

        if [ "$col1" = 'ref:' ]
        then
          refs=${col2/#refs\/heads\//}
        else
          is_hash=1
          refs=${col1::7}
        fi

        break
      fi

      cwd="$(cd "${cwd}/.." && pwd)"
    done

    local prompt=

    # exit code
    [ "$exit_code" -ne 0 ] && prompt="${prompt} ${red}${exit_code}${reset}"

    # some git infomations
    if [ -n "$is_git" ]
    then
      [ "$repo_type" = 'git' ] &&
        prompt="${prompt} ${cyan}(${repo_type}:${reset}" || 
        prompt="${prompt} ${cyan}(${red}${repo_type}${reset}${cyan}:${reset}"

      [ -z "$is_hash" ] &&
        prompt="${prompt}${cyan}${refs})${reset}" ||
        prompt="${prompt}${red}${refs}${reset}${cyan})${reset}"
    fi

    # yarn and lerna
    if [ -n "$is_yarn" ] && [ -n "$is_lerna" ]
    then
      prompt="${prompt} ${yellow}(yarn:lerna)${reset}"
    elif [ -n "$is_yarn" ]
    then
      prompt="${prompt} ${yellow}(yarn)${reset}"
    elif [ -n "$is_lerna" ]
    then
      prompt="${prompt} ${yellow}(lerna)${reset}"
    fi

    # in vim
    [ -n "$VIM" ] && [ -n "$VIMRUNTIME" ] && prompt="${prompt} ${cyan}(vim)${reset}"

    printf -- "${prompt}"
  }

  __print_PS1() {
    local -r green='\e[01;32m'
    local -r reset='\e[00m'

    # /current/dir error (git:branch or revision) (yarn:lerna) (vim)
    # username@hostname$ _
    printf -- "${green}\w${reset}\$(__print_status \$?)\n\u@\h$ "
  }

  export PS1=$(__print_PS1)
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

  # always use terminal multiplexer
  [ "$TERM" != 'screen' ] && [ "$TERM" != 'dumb' ] && [ -z "$VIM" ] && tmux
}

__main "$@"

unset -f __main

# vim:ft=sh:fdm=marker:fen:
