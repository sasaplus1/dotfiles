#!/bin/bash
# NOTE: shebang for shellcheck

# return if not interactive
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
[ -z "$PS1" ] && return

__main() {
  unset -f __main

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

  if [ "$os" == 'macos' ] && arch -arm64e echo -n >/dev/null 2>&1
  then
    local -r apple_silicon=1
    export __APPLE_SILICON=1
    readonly __APPLE_SILICON
  fi

  #-----------------------------------------------------------------------------

  export EDITOR=vim
  export PAGER=less

  #-----------------------------------------------------------------------------

  # fix typo of path for cd command
  shopt -s cdspell

  # stop flow mode (disable C-s and C-q)
  # stty stop undef
  # stty start undef
  stty -ixon

  if [ "$SHLVL" -eq 1 ]
  then
    export HISTSIZE=10000
    export HISTFILESIZE=10000
    export HISTTIMEFORMAT='%Y/%m/%d %T '
    export HISTCONTROL=ignoredups:erasedups
  fi

  #-----------------------------------------------------------------------------

  local -r macports_prefix=/opt/local
  export __MACPORTS_PREFIX=$macports_prefix
  readonly __MACPORTS_PREFIX

  local -r dotlocal_prefix="$HOME/.local"
  export __DOTLOCAL_PREFIX=$dotlocal_prefix
  readonly __DOTLOCAL_PREFIX

  #-----------------------------------------------------------------------------

  # tmux shell {{{
  for shell_path in \
    "$dotlocal_prefix/bin/bash" \
    "$macports_prefix/bin/bash" \
    "$HOMEBREW_PREFIX/bin/bash" \
    /bin/bash \
    /bin/sh
  do
    [ -n "$TMUX_SHELL" ] && break
    [ -x "$shell_path" ] && export TMUX_SHELL="$shell_path"
  done
  # }}}

  #-----------------------------------------------------------------------------

  # bash-completion {{{
  if [ -z "$BASH_COMPLETION" ]
  then
    for bash_completion in \
      "$macports_prefix/etc/profile.d/bash_completion.sh" \
      "$macports_prefix/etc/bash_completion" \
      "$HOMEBREW_PREFIX/etc/bash_completion" \
      /etc/bash_completion
    do
      [ -n "$BASH_COMPLETION" ] && break
      # shellcheck disable=SC1090
      [ -f "$bash_completion" ] && source "$bash_completion"
    done
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # NOTE: lazy load completion https://qiita.com/kawaz/items/ba6140bca32bbd3cb928

  # gh-completion {{{
  # NOTE: see fzf section
  # }}}

  # nvm-completion {{{
  __nvm_completion() {
    unset -f __nvm_completion
    complete -r nvm

    local -r completion="$NVM_DIR/bash_completion"

    # shellcheck disable=SC1090
    [ -f "$completion" ] && source "$completion" && return 124
  }
  complete -F __nvm_completion nvm
  # }}}

  # nodebrew-completion {{{
  __nodebrew_completion() {
    unset -f __nodebrew_completion
    complete -r nodebrew

    local -r completion="$HOME/.nodebrew/completions/bash/nodebrew-completion"

    # shellcheck disable=SC1090
    [ -f "$completion" ] && source "$completion" && return 124
  }
  complete -F __nodebrew_completion nodebrew
  # }}}

  # npm-completion {{{
  __npm_completion() {
    unset -f __npm_completion
    complete -r npm
    eval "$(npm completion)" && return 124
  }
  complete -F __npm_completion npm
  # }}}

  # rbenv-completion {{{
  __rbenv-completion() {
    unset -f __rbenv-completion
    complete -r rbenv

    local -r completion="$HOME/.rbenv/completions/rbenv.bash"

    # shellcheck disable=SC1090
    [ -f "$completion" ] && source "$completion" && return 124
  }
  complete -F __rbenv-completion rbenv
  # }}}

  #-----------------------------------------------------------------------------

  # NOTE: lazy load command https://qiita.com/uasi/items/80865646607b966aedc8

  # direnv {{{
  if type direnv >/dev/null 2>&1
  then
    eval "$(direnv hook bash)"
  fi
  # }}}

  # nvm {{{
  # shellcheck disable=SC1091
  [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  # }}}

  # rbenv {{{
  rbenv() {
    unset -f rbenv
    eval "$(rbenv init -)"
    rbenv "$@"
  }
  # }}}

  # rustup {{{
  # shellcheck disable=SC1091
  [ -r "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
  # }}}

  # zoxide or z {{{
  local -r z="$GHQ_ROOT/github.com/rupa/z/z.sh"

  if type zoxide >/dev/null 2>&1
  then
    eval "$(zoxide init bash)"
  elif [ -s "$z" ]
  then
    # shellcheck disable=SC1090
    source "$z"
  fi
  # }}}

  # cocproxy for nginx {{{
  cocproxy() {
    (cd "$HOME/.cocproxy" && nginx -p . -c "$HOME/.cocproxy.nginx.conf")
  }
  # }}}

  # fzf {{{
  for fzf_completion in \
    "$macports_prefix/share/fzf/shell/completion.bash" \
    "$HOMEBREW_PREFIX/opt/fzf/shell/completion.bash"
  do
    # shellcheck disable=SC1090
    [ -r "$fzf_completion" ] && source "$fzf_completion" && break
  done

  local fzf_options=

  fzf_options='--border --cycle --height=80%'
  fzf_options="${fzf_options} --info=hidden --layout=reverse --preview-window=right"
  fzf_options="${fzf_options} --bind ctrl-j:preview-down,ctrl-k:preview-up"

  export FZF_DEFAULT_OPTS="$fzf_options"

  fzf() {
    local position=

    if [[ "$TERM" =~ ^(screen|tmux) ]] && type tmux >/dev/null 2>&1
    then
      local -r width="$(tmux display-message -p '#{window_width},#{pane_width}')"

      local -r window_width="${width%%,*}"
      local -r pane_width="${width##*,}"

      [ "$window_width" -ne "$pane_width" ] && position='--preview-window=bottom'
    fi

    if [ -n "$position" ]
    then
      command fzf "$position" "$@"
    else
      command fzf "$@"
    fi
  }

  # get subcommand name, for fzf completions
  # param $1: command name
  # return: subcommand name
  __detect_subcommand() {
    local -r command="$1"

    for ((i = 0; i < COMP_CWORD; i++))
    do
      [ "${COMP_WORDS[i]}" == "$command" ] && local -r index=$i && break
    done

    printf -- '%s' "${COMP_WORDS[index+1]}"
  }

  # docker complete by fzf with preview
  _fzf_complete_docker() {
    local -r command="${FUNCNAME[0]##*_}"
    local -r subcommand="$(__detect_subcommand "$command")"

    case "$subcommand" in
      exec|stop)
        _fzf_complete --multi -- "$@" < <(docker ps | sed 1d)
        ;;
      rm)
        _fzf_complete --multi -- "$@" < <(docker ps -a | sed 1d)
        ;;
      rmi)
        _fzf_complete --multi -- "$@" < <(docker images | sed 1d)
        ;;
      *)
        # call original completion
        _fzf_handle_dynamic_completion "$command" "$@"
        ;;
    esac
  }
  _fzf_complete_docker_post() {
    awk '{ print $1 }'
  }
  complete -F _fzf_complete_docker -o default -o bashdefault docker

  # git complete by fzf with preview
  _fzf_complete_git() {
    local -r command="${FUNCNAME[0]##*_}"
    local -r subcommand="$(__detect_subcommand "$command")"

    case "$subcommand" in
      checkout|co)
        _fzf_complete --ansi --preview='git show --color=always {}' -- "$@" < \
          <(git branch --all --format='%(refname:short)')
        ;;
      cherry-pick|cp|rebase)
        local -r format='%C(yellow)%h%C(reset) %C(magenta)[%ad]%C(reset) %C(cyan)@%an%C(reset) %C(cyan)@%cn%C(reset)%C(auto)%d%C(reset) %s'
        # shellcheck disable=SC2016
        local -r preview='git show --color=always "$(echo {} | grep -Eo \[0-9a-f\]\{7,40\} | head -n 1)" 2>/dev/null'

        _fzf_complete --ansi --preview="$preview" -- "$@" < \
          <(git log --all --color=always --graph --date=short --format="$format")
        ;;
      *)
        # call original completion
        _fzf_handle_dynamic_completion "$command" "$@"
        ;;
    esac
  }
  _fzf_complete_git_post() {
    local -r subcommand="$(__detect_subcommand git)"

    case "$subcommand" in
      checkout|co)
        head -n 1
        ;;
      cherry-pick|cp|rebase)
        grep -Eo '[0-9a-f]{7,40}' | head -n 1
        ;;
    esac
  }
  complete -F _fzf_complete_git -o default -o bashdefault git

  # gh complete by fzf with preview
  _fzf_complete_gh() {
    local -r command="${FUNCNAME[0]##*_}"
    local -r subcommand="$(__detect_subcommand "$command")"

    case "$subcommand" in
      gist)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh gist view {1}" -- "$@" < \
          <(gh gist list)
        ;;
      issue)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh issue view {1}" -- "$@" < \
          <(gh issue list --json number,title,state -q '.[] | "#\(.number)\t\(.state)\t\(.title)"')
        ;;
      pr)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh pr view {1}" -- "$@" < \
          <(gh pr list --json number,title -q '.[] | "#\(.number)\t\(.title)"')
        ;;
      release)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh release view {1}" -- "$@" < \
          <(gh release list)
        ;;
      repo)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh repo view {+1}" -- "$@" < \
          <(gh repo list --source --limit 200 --json owner,name -q '.[] | "\(.owner.login)/\(.name)"')
        ;;
      *)
        # call original completion
        _fzf_handle_dynamic_completion "$command" "$@"
        ;;
    esac
  }
  _fzf_complete_gh_post() {
    awk '{ sub(/^#/, "", $1); print $1 }'
  }

  # lazy loading gh-completion
  __gh_completion() {
    unset -f __gh_completion
    complete -r gh

    eval "$(gh completion --shell bash)" && \
      complete -F _fzf_complete_gh -o default -o bashdefault gh && \
      return 124
  }
  complete -F __gh_completion gh

  # tig complete by fzf with preview
  _fzf_complete_tig() {
    _fzf_complete --preview='git show --color=always {}' -- "$@" < <(git branch --all --format='%(refname:short)')
  }
  complete -F _fzf_complete_tig -o default -o bashdefault tig
  # }}}

  # vim {{{
  local -r pvim="$HOME/Binary/vim/bin/portable-vim"
  local -r lvim="$HOME/.local/bin/vim"
  local -r mvim="$HOME/.ghq/github.com/sasaplus1/macos-vim/usr/bin/vim"

  [ -x "$pvim" ] && export EDITOR="$pvim"
  [ -x "$lvim" ] && export EDITOR="$lvim"
  [ -x "$mvim" ] && export EDITOR="$mvim"

  if [ -n "$VIM_TERMINAL" ]
  then
    # https://vim-jp.org/vimdoc-en/terminal.html#terminal-api
    vim() {
      for _ in $(seq $#)
      do
        printf -- '%b["drop","%s"]%b' '\x1b]51;' "$PWD/$1" '\x07' &
        shift
      done
    }
  else
    vim() {
      if [ -x "$mvim" ]
      then
        "$mvim" "$@"
      elif [ -x "$lvim" ]
      then
        "$lvim" "$@"
      elif [ -x "$pvim" ]
      then
        "$pvim" "$@"
      else
        command vim "$@"
      fi
    }
  fi
  # }}}

  # github-slug.sh {{{
  export _GITHUB_SLUG_COMMAND=slug

  __lazy-github-slug() {
    unset -f __lazy-github-slug
    # shellcheck disable=SC1091
    source "$HOME/.ghq/github.com/sasaplus1/github-slug.sh/github-slug.sh" 2>/dev/null
    __github-slug "$@"
    eval "$_GITHUB_SLUG_COMMAND"'() { __github-slug "$@"; }'
  }
  eval "$_GITHUB_SLUG_COMMAND"'() { __lazy-github-slug "$@"; }'
  # }}}

  #-----------------------------------------------------------------------------

  # functions and aliases {{{
  server() {
    python -m SimpleHTTPServer "$@"
  }

  fake-dev() {
    nginx -p . -c "$(ghq list -p fake-dev)/fake-dev.conf"
  }

  add-ssh-key() {
    for key in $(find "$HOME/.ssh" -type f -name '*.pub' -print0 | xargs -0)
    do
      printf -- '%s\0' "${key%.*}"
    done | xargs -0 command ssh-add
  }

  # incremental search and change directory
  ccd() {
    # mdfind -onlyin "$(pwd)" "kMDItemContentType == public.folder" 2>/dev/null

    local repo_cmd=

    if type ghq >/dev/null 2>&1
    then
      repo_cmd='ghq list --full-path'
    else
      # shellcheck disable=SC2016
      repo_cmd='find "$GHQ_ROOT" -mindepth 3 -maxdepth 3 -type d -print'
    fi

    if type zoxide >/dev/null 2>&1
    then
      local -r z_cmd='zoxide query --list 2>&1'
    elif [ "$(type -t z)" == 'function' ]
    then
      # shellcheck disable=SC2016
      local -r z_cmd='z -l 2>&1 | while read _ dir; do echo "$dir"; done'
    fi

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

  git-hash() {
    # shellcheck disable=SC2016
    local -r preview='git show --color=always "$(echo {} | grep -Eo \[0-9a-f\]\{7,40\} | head -n 1)" 2>/dev/null'

    git log --all --color=always --graph --oneline | fzf --ansi --preview="$preview" | grep -Eo '[0-9a-f]{7,40}' | head -n 1
  }

  # cd to repository root
  rr() {
    # error message print to stderr if failed
    git rev-parse --is-inside-work-tree >/dev/null && cd "$(git rev-parse --show-toplevel)" || return
  }

  #-----------------------------------------------------------------------------

  # switch tmux session
  if type tmux >/dev/null 2>&1
  then
    switch-session() {
      tmux switch-client -t "$(tmux list-sessions | fzf --no-multi | awk '{ print $1 }')"
    }
  fi

  # change to urxvt font size
  # from https://gist.github.com/anekos/5938365
  if type urxvt >/dev/null 2>&1
  then
    set-urxvt-font-size() {
      local -r old_name=$(grep -i '^\s*urxvt.font' "$HOME/.Xdefaults" | cut -d: -f2-)
      local -r new_name=$(printf -- '%b' "$old_name" | sed -e 's/:\(pixel\)\?size=[0-9]\+/'":\1size=$1/")

      [ -n "$TMUX" ] && printf -- '\ePtmux;\e'
      printf -- '\e]50;%s\007' "$new_name"
      # shellcheck disable=SC1003
      [ -n "$TMUX" ] && printf -- '\e\\'
    }
  fi
  # }}}

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

    # origin's default branch name
    local default_branch=

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

        [[ "$head_dir" =~ ^\.\.?\/ ]] &&
          # maybe head_dir is relative path
          head_file="${cwd}/${head_dir}/HEAD" ||
          # maybe head_dir is absolute path
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
        local col1=
        local col2=

        is_git=1

        [ -z "$repo_type" ] && repo_type=git
        [ -z "$head_file" ] && head_file="${cwd}/.git/HEAD"

        read -r col1 col2 < "$head_file"

        if [ "$col1" == 'ref:' ]
        then
          refs=${col2/#refs\/heads\//}
        else
          is_hash=1
          refs=${col1::7}
        fi

        local origin_head_file="${cwd}/.git/refs/remotes/origin/HEAD"

        if [ -f "$origin_head_file" ]
        then
          local default_branch=

          read -r _ default_branch < "$origin_head_file"
          default_branch="${default_branch/refs\/remotes\/origin\//}"
        fi

        break
      fi

      cwd="$(cd "${cwd}/.." && pwd)"
    done

    local prompt=

    # architecture
    [ -n "$__APPLE_SILICON" ] && [ "$(uname -m)" != 'arm64' ] &&
      prompt="${prompt} ${red}[x86_64]${reset}"

    # exit code
    [ "$exit_code" -ne 0 ] && prompt="${prompt} ${red}${exit_code}${reset}"

    # some git infomations
    if [ -n "$is_git" ]
    then
      [ "$repo_type" == 'git' ] &&
        prompt="${prompt} ${cyan}(${repo_type}:${reset}" || 
        prompt="${prompt} ${cyan}(${red}${repo_type}${reset}${cyan}:${reset}"

      [ -n "$default_branch" ] &&
        prompt="${prompt}${yellow}${default_branch}${reset}${cyan}:${reset}"

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
    [ -n "$VIM_TERMINAL" ] && prompt="${prompt} ${cyan}(vim)${reset}"

    # in neovim
    [ -n "$NVIM" ] && prompt="${prompt} ${cyan}(neovim)${reset}"

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

  # NOTE: SC2155
  # https://github.com/koalaman/shellcheck/wiki/SC2155
  PS1=$(__print_PS1)
  export PS1
  # }}}

  alias gt='git'
  alias gti='git'

  if [ -n "$apple_silicon" ]
  then
    alias armsh='arch -arm64e /bin/bash'
    alias x86sh='arch -x86_64 /bin/bash'
  fi

  case "$os" in
    macos)
      alias ls='ls -G'
      alias grep='grep --color=auto'
      alias ios='open -a "Simulator" || open -a "iOS Simulator" || open -a "iPhone Simulator"'
      ;;
    linux)
      alias crontab='crontab -i'
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
      ;;
    *)
      ;;
  esac

  # load .bashrc.local
  # shellcheck disable=SC1091
  [ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

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
  if [ -z "$TMUX" ] && [ -z "$VIM_TERMINAL" ] && [ ! -f '/.dockerenv' ]
  then
    type tmux >/dev/null 2>&1 && command tmux
  fi
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
