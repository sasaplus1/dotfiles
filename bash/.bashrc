#!/bin/bash

__main() {
  local os=

  case "$OSTYPE" in
    darwin*) os=macos ;;
    linux*)  os=linux ;;
    *)       os=      ;;
  esac

  local is_dumb=
  local is_interactive=

  if [ "$TERM" == 'dumb' ] || [ -z "$PS1" ]
  then
    is_dumb=1
  else
    is_interactive=1
  fi

  #-----------------------------------------------------------------------------

  local homebrew_dir=

  if [ "$os" = 'macos' ]
  then
    [ -d '/usr/local/Homebrew' ] && homebrew_dir=/usr/local
    # NOTE: my original location
    [ -d "$HOME/Homebrew" ] && homebrew_dir=$HOME/Homebrew
  fi

  if [ "$os" = 'linux' ]
  then
    [ -d '/home/linuxbrew/.linuxbrew/Homebrew' ] && homebrew_dir=/home/linuxbrew/.linuxbrew
    [ -d "$HOME/.linuxbrew/Homebrew" ] && homebrew_dir=$HOME/.linuxbrew
  fi

  local homebrew_infopath=$homebrew_dir/share/info
  local homebrew_manpath=$homebrew_dir/share/man
  local homebrew_path=$homebrew_dir/bin

  export INFOPATH=$homebrew_infopath:${INFOPATH//$homebrew_infopath/}
  export MANPATH=$homebrew_manpath:${MANPATH//$homebrew_manpath/}
  export PATH=$homebrew_path:${PATH//$homebrew_path/}

  local homebrew_prefix=

  # NOTE: brew --prefix is very slow https://github.com/Homebrew/brew/issues/3097
  homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"

  [ -d "$homebrew_prefix" ] && export HOMEBREW_DIR=$homebrew_dir

  #-----------------------------------------------------------------------------

  # bash-completion {{{
  if [ -n "$is_interactive" ] && [ -z "$BASH_COMPLETION" ]
  then
    case "$os" in
      macos)
        # shellcheck disable=SC1090
        source "$homebrew_prefix/etc/bash_completion" 2>/dev/null
        ;;
      linux)
        # shellcheck disable=SC1091
        source /etc/bash_completion 2>/dev/null
        ;;
    esac
  fi
  # }}}

  #-----------------------------------------------------------------------------

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

    local homebrew_prefix=
    homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"

    # shellcheck disable=SC1090
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

    local homebrew_prefix=
    homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"

    # shellcheck disable=SC1090
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
    # shellcheck disable=SC1090
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

  # gh-completion
  __gh_completion() {
    unset -f __gh_completion
    complete -r gh
    eval "$(gh completion --shell bash)" && return 124
  }
  complete -F __gh_completion gh
  # }}}

  # z {{{
  # lazy loading
  z() {
    unset -f z

    local ghq_prefix=
    ghq_prefix="$(ghq root)"

    # shellcheck disable=SC1090
    source "$ghq_prefix/github.com/rupa/z/z.sh" 2>/dev/null
    # NOTE: call _z function directly, because z is alias
    _z "$@"
  }

  # z-completion
  __z_completion() {
    unset -f __z_completion
    complete -r z

    local ghq_prefix=
    ghq_prefix="$(ghq root)"

    # shellcheck disable=SC1090
    source "$ghq_prefix/github.com/rupa/z/z.sh" 2>/dev/null && return 124
  }
  complete -F __z_completion z
  # }}}

  # go {{{
  local go_gopath=$HOME/.go
  local go_gopath_bin=$go_gopath/bin
  export GOPATH=$go_gopath
  export PATH=$go_gopath_bin:${PATH//$go_gopath_bin/}
  # }}}

  # ghq {{{
  export GHQ_ROOT=$HOME/.ghq
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

  # fzf {{{
  local fzf_opts=

  fzf_opts=()
  fzf_opts+=('--border --cycle --height=60% --info=hidden --layout=reverse --preview-window=right')
  fzf_opts+=('--bind ctrl-j:preview-down,ctrl-k:preview-up')

  export FZF_DEFAULT_OPTS=${fzf_opts[*]}

  fzf() {
    local fzf=

    fzf="$(type -tP fzf)"

    local position=

    if [[ "$TERM" =~ ^(screen|tmux) ]] && type tmux >/dev/null 2>&1
    then
      local window_width=
      local pane_width=

      window_width="$(tmux display-message -p "#{window_width}")"
      pane_width="$(tmux display-message -p "#{pane_width}")"

      [ "$window_width" -ne "$pane_width" ] && position='--preview-window=bottom'
    fi

    if [ -n "$position" ]
    then
      "$fzf" "$position" "$@"
    else
      "$fzf" "$@"
    fi
  }

  # shellcheck disable=SC1090
  source "$homebrew_prefix/opt/fzf/shell/completion.bash" 2>/dev/null
  # }}}

  # hub {{{
  hub() {
    local hub_bin=

    hub_bin="$(type -tP hub)"

    if git remote -v | grep github.com >/dev/null 2>&1
    then
      host='github.com'
    else
      host="$(git config --get-all remote.origin.url | awk -F '[:/]' '{ sub(/^[^@]*@/, "", $4); print $4 }')"
    fi

    GITHUB_HOST="$host" "$hub_bin" "$@"
  }

  # hub-completion
  __hub_completion() {
    unset -f __hub_completion
    complete -r hub

    local homebrew_prefix=
    homebrew_prefix="$(dirname "$(dirname "$(type -tP brew)")")"

    # shellcheck disable=SC1090
    source "$homebrew_prefix/opt/hub/etc/bash_completion.d/hub.bash_completion.sh" 2>/dev/null && return 124
  }
  complete -F __hub_completion hub
  # }}}

  # vim {{{

  # macvim
  # local macvim=/Applications/MacVim.app/Contents/MacOS
  # [ -d "$macvim" ] &&
  #   export PATH=$macvim:${PATH//$macvim/} &&
  #   export EDITOR="$macvim/Vim" &&
  #   vim() {
  #     local macvim=/Applications/MacVim.app/Contents/MacOS

  #     "$macvim/Vim" "$@"
  #   }

  # macvim from homebrew-cask
  # local macvim=$HOME/Caskroom/macvim-kaoriya/$(ls $HOME/Caskroom/macvim-kaoriya 2>/dev/null)/MacVim.app/Contents/MacOS
  # [ -d "$macvim" ] &&
  #   export PATH=$macvim:${PATH//$macvim/} &&
  #   alias vim="$macvim/Vim \"\$@\"" &&
  #   export EDITOR="$macvim/Vim"

  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/portable-vim
  local pvim=$HOME/Binary/vim
  [ -d "$pvim" ] &&
    local pvim_manpath=$pvim/share/man &&
    local pvim_path=$pvim/bin &&
    export MANPATH=$pvim_manpath:${MANPATH//$pvim_manpath/} &&
    export PATH=$pvim_path:${PATH//$pvim_path/} &&
    export EDITOR="$pvim_path/portable-vim"

  # my KaoriYa Vim for macOS
  # via https://github.com/sasaplus1/macos-vim
  local mvim=$HOME/.ghq/github.com/sasaplus1/macos-vim
  [ -x "$mvim/usr/bin/vim" ] &&
    local mvim_manpath=$mvim/share/man &&
    local mvim_path=$mvim/usr/bin &&
    export MANPATH=$mvim_manpath:${MANPATH//$mvim_manpath/} &&
    export PATH=$mvim_path:${PATH//$mvim_path/} &&
    export EDITOR="$mvim_path/vim"

  vim() {
    local mvim=
    local pvim=

    mvim="$HOME/.ghq/github.com/sasaplus1/macos-vim/usr/bin/vim"
    pvim="$HOME/Binary/vim/bin/portable-vim"

    if [ -x "$mvim" ]
    then
      export EDITOR="$mvim"
      "$mvim" "$@"
    elif [ -x "$pvim" ]
    then
      export EDITOR="$pvim"
      "$pvim" "$@"
    else
      export EDITOR="vim"
      vim "$@"
    fi
  }

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

  INFOPATH="$(printf -- '%b' "$INFOPATH" | sed -e 's/:\{2,\}/:/' -e 's/:$//')"
  MANPATH="$(printf -- '%b' "$MANPATH" | sed -e 's/:\{2,\}/:/' -e 's/:$//')"
  PATH="$(printf -- '%b' "$PATH" | sed -e 's/:\{2,\}/:/' -e 's/:$//')"

  #-----------------------------------------------------------------------------

  # ssh-agent {{{
  local ssh_agent=/usr/bin/ssh-agent
  local ssh_agent_info=$HOME/.ssh-agent-info

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

  # up.sh {{{
  up() {
    unset -f up
    # shellcheck disable=SC1090
    source "$HOME/.ghq/github.com/shannonmoeller/up/up.sh" 2>/dev/null
    up "$@"
  }
  # }}}

  # down.sh {{{
  export _DOWN_CMD=dw
  dw() {
    unset -f dw
    # shellcheck disable=SC1090
    source "$HOME/.ghq/github.com/sasaplus1/down.sh/down.sh" 2>/dev/null
    dw "$@"
  }
  # }}}

  # github-slug.sh {{{
  export _GITHUB_SLUG_COMMAND=slug
  __lazy-github-slug() {
    unset -f __lazy-github-slug
    # shellcheck disable=SC1090
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
    python -m SimpleHTTPServer "$@"
  }

  fake-dev() {
    nginx -p . -c "$(ghq list -p fake-dev)/fake-dev.conf"
  }

  # incremental search and change directory
  ccd() {
    # mdfind -onlyin "$(pwd)" "kMDItemContentType == public.folder" 2>/dev/null

    # shellcheck disable=SC2016
    local repo_cmd='find "$HOME/.ghq" -mindepth 3 -maxdepth 3 -type d -print'

    # shellcheck disable=SC2016
    local z_cmd='z -l 2>&1 | while read _ dir; do echo "$dir"; done'

    local git_dir=
    local git_cmd=

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
    then
      git_dir="$(git rev-parse --show-toplevel)"
      git_cmd="git ls-tree -dr --name-only --full-name HEAD '$git_dir' | sed -e 's|^|${git_dir}/|'"
    fi

    local fzf_preview=

    if type bat >/dev/null 2>&1
    then
      fzf_preview='bat --color=always -pp -r :60 {}/README.* 2>/dev/null || ls -1a {}'
    else
      fzf_preview='head -n 60 {}/README.* 2>/dev/null || ls -1a {}'
    fi

    # shellcheck disable=SC2164,SC2145
    cd "$(cat <(eval "$repo_cmd") <(eval "$z_cmd") <(eval "$git_cmd") | sort -u | fzf --query="$@" --preview="$fzf_preview")"
  }

  prr() {
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != 'true' ]
    then
      printf -- '%s\n' 'not within git repository.'
      return 1
    fi

    hub pr show "$(cat <(hub pr list "$@") <(hub issue "$@") | fzf | awk '{ sub(/^#/, "", $1); print $1 }')"
  }

  pv() {
    local fzf_preview=

    if type bat >/dev/null 2>&1
    then
      fzf_preview='bat --color=always -pp -r :60 {} 2>/dev/null || find {} -maxdepth 1 -print'
    else
      fzf_preview='head -n 60 {} 2>/dev/null || find {} -maxdepth 1 -print'
    fi

    local selected=

    selected="$(find "$PWD" -maxdepth 1 -print | fzf --preview="$fzf_preview")"

    if [ -d "$selected" ]
    then
      cd "$selected" || exit 1
    elif [ -r "$selected" ]
    then
      "$EDITOR" "$selected"
    fi
  }

  # cd to repository root
  rr() {
    cd "$(git rev-parse --show-toplevel)" || exit 1
  }

  # remove docker containers
  d-rm() {
    # shellcheck disable=SC2145
    docker ps -a | sed 1d | fzf --multi --query="$@" | awk '{ print $1 }' | xargs docker rm
  }

  # remove docker images
  d-rmi() {
    # shellcheck disable=SC2145
    docker images | sed 1d | fzf --multi --query="$@" | awk '{ print $3 }' | xargs docker rmi --force
  }

  # execute command in container
  d-sh() {
    # shellcheck disable=SC2145
    docker exec -it "$(docker ps | sed 1d | fzf --query="$@" | awk '{ print $1 }' | sed -n 1p)" "${1:-sh}"
  }

  d-stop() {
    # shellcheck disable=SC2145
    docker ps | sed 1d | fzf --multi --query="$@" | awk '{ print $1 }' | xargs -n 1 docker stop
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
      local old_name=
      old_name=$(grep -i '^\s*urxvt.font' "$HOME/.Xdefaults" | cut -d: -f2-)

      local new_name=
      new_name=$(printf -- '%b' "$old_name" | sed -e 's/:\(pixel\)\?size=[0-9]\+/'":\1size=$1/")

      [ -n "$TMUX" ] && printf -- '\ePtmux;\e'
      printf -- '\e]50;%s\007' "$new_name"
      # shellcheck disable=SC1003
      [ -n "$TMUX" ] && printf -- '\e\\'
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
        read -r _ head_dir < "${cwd}/.git"
        head_file="${head_dir}/HEAD"

        [[ "$head_file" =~ \.git\/worktrees ]] &&
          repo_type=git-worktree ||
          repo_type=git-submodule
      fi

      # vcs info
      # $ vcprompt -f '%n:%b:%r' 2>/dev/null
      # is too slow
      # $ git rev-parse --is-inside-work-tree
      # too
      if [ -d "${cwd}/.git" ]
      then
        local col1
        local col2

        is_git=1

        [ -z "$repo_type" ] && repo_type=git
        [ -z "$head_file" ] && head_file="${cwd}/.git/HEAD"

        read -r col1 col2 < "$head_file"

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

    printf -- '%b' "${prompt}"
  }

  __print_PS1() {
    local -r green='\e[01;32m'
    local -r reset='\e[00m'

     # NOTE: need double escape because bash says `missing unicode digit for \u`
    local -r u='\\u'

    # /current/dir error (git:branch or revision) (yarn:lerna) (vim)
    # username@hostname$ _
    printf -- '%b' "${green}\w${reset}\$(__print_status \$?)\n${u}@\h$ "
  }

  export PS1=
  PS1=$(__print_PS1)
  # }}}

  # load .bashrc.local
  # shellcheck disable=SC1090
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
  if [[ "$TERM" =~ ^(screen|tmux) ]]
  then
    return 0
  fi
  if [ -z "$is_dumb" ] && [ -z "$TMUX" ] && [ -z "$VIM" ] && [ ! -f '/.dockerenv' ]
  then
    type tmux >/dev/null 2>&1 && tmux
  fi
}

__main "$@"

unset -f __main

# vim:ft=sh:fdm=marker:fen:
