#!/bin/bash
# NOTE: shebang for shellcheck

# return if not interactive
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
#[ -z "$PS1" ] && return
[[ ! "$-" =~ i ]] && return

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

  # current session architecture
  # `uname -m` prints `x86_64` when `arch -x86_64 /bin/bash` executed
  # e.g. x86_64, arm64
  # local -r cpu="$(uname -m)"

  # Is this machine can run Apple Silicon binaries?
  if [ "$os" == 'macos' ] && arch -arm64e echo -n >/dev/null 2>&1
  then
    local -r apple_silicon=1
    export __APPLE_SILICON=1
    readonly __APPLE_SILICON
  fi

  #-----------------------------------------------------------------------------

  # NOTE: tmux overwrite TERM_PROGRAM and TERM_PROGRAM_VERSION
  # ex: Terminal.app = Apple_Terminal, 440
  # ex: VSCode       = vscode, 1.68.1
  export ORIGINAL_TERM_PROGRAM="$TERM_PROGRAM"
  readonly ORIGINAL_TERM_PROGRAM
  export ORIGINAL_TERM_PROGRAM_VERSION="$TERM_PROGRAM_VERSION"
  readonly ORIGINAL_TERM_PROGRAM_VERSION

  #-----------------------------------------------------------------------------

  update_path() {
    # shellcheck disable=SC1091
    source "$HOME/.sh_path"
  }

  if [ ! -f "$HOME/.cache/sh_user_path" ] || [ "$(readlink -f "$HOME/.sh_path")" -nt "$HOME/.cache/sh_user_path" ]
  then
    update_path
  fi

  #-----------------------------------------------------------------------------

  # for Ubuntu
  type batcat >/dev/null 2>&1 && bat() { batcat "$@"; }

  #-----------------------------------------------------------------------------

  # highlighting manpages
  # export LESS_TERMCAP_mb=$'\E[01;31m'
  # export LESS_TERMCAP_md=$'\E[01;38;5;74m'
  # export LESS_TERMCAP_me=$'\E[0m'
  # export LESS_TERMCAP_se=$'\E[0m'
  # export LESS_TERMCAP_so=$'\E[38;5;246m'
  # export LESS_TERMCAP_ue=$'\E[0m'
  # export LESS_TERMCAP_us=$'\E[04;38;5;146m'

  #-----------------------------------------------------------------------------

  # fix typo of path for cd command
  shopt -s cdspell

  #-----------------------------------------------------------------------------

  local -r macports_prefix=/opt/local
  export __MACPORTS_PREFIX=$macports_prefix
  readonly __MACPORTS_PREFIX

  local -r dotlocal_prefix="$HOME/.local"
  export __DOTLOCAL_PREFIX=$dotlocal_prefix
  readonly __DOTLOCAL_PREFIX

  #-----------------------------------------------------------------------------

  # nix(by devbox) {{{
  # NOTE: https://github.com/NixOS/nix/issues/13255
  local -r nix=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # shellcheck disable=SC1090
  [ -r "$nix" ] && unset __ETC_PROFILE_NIX_SOURCED && source "$nix"
  # }}}

  #-----------------------------------------------------------------------------

  # Bitwarden as ssh-agent {{{
  for sock in \
    "$HOME/.bitwarden-ssh-agent.sock" \
    "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock" \
    "$HOME/snap/bitwarden/current/.bitwarden-ssh-agent.sock" \
    "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
  do
    [ -S "$sock" ] && export SSH_AUTH_SOCK="$sock" && break
  done
  # }}}

  #-----------------------------------------------------------------------------

  # tmux shell {{{
  for shell_path in \
    "$dotlocal_prefix/bin/bash" \
    "$macports_prefix/bin/bash" \
    "$HOMEBREW_PREFIX/bin/bash" \
    /bin/bash \
    /bin/sh
  do
    # break if already set
    [ -n "$TMUX_SHELL" ] && break
    [ -x "$shell_path" ] && export TMUX_SHELL="$shell_path" && break
  done
  # }}}

  #-----------------------------------------------------------------------------

  # bash-completion {{{
  for bash_completion in \
    "$macports_prefix/etc/profile.d/bash_completion.sh" \
    "$macports_prefix/etc/bash_completion" \
    "$HOMEBREW_PREFIX/etc/bash_completion" \
    /etc/bash_completion
  do
    # break if already set
    [ -n "$BASH_COMPLETION" ] && break
    # shellcheck disable=SC1090
    [ -f "$bash_completion" ] && source "$bash_completion" && break
  done
  # }}}

  #-----------------------------------------------------------------------------

  # NOTE: lazy load completion https://qiita.com/kawaz/items/ba6140bca32bbd3cb928

  # devbox completion {{{
  # __devbox_completion() {
  #   unset -f __devbox_completion
  #   complete -r devbox
  #   eval "$(devbox completion bash)" && return 124
  # }
  # complete -F __devbox_completion devbox
  # }}}

  # gh-completion {{{
  # NOTE: see fzf section
  # }}}

  # gw-completion {{{
  __gw-completion() {
    unset -f __gw-completion
    local cmd="${__GW_CMD:-gw}"
    complete -r "$cmd"
    # Initialize gw function by loading the actual script
    # shellcheck disable=SC1091
    source "${GHQ_ROOT:-$HOME/.ghq}/github.com/sasaplus1/git-worktree.bash/git-worktree.bash" 2>/dev/null
    eval "$("${cmd}" completion)" && return 124
  }
  complete -F __gw-completion "${__GW_CMD:-gw}"
  # }}}

  # npm-completion {{{
  __npm_completion() {
    unset -f __npm_completion
    complete -r npm
    eval "$(npm completion)" && return 124
  }
  complete -F __npm_completion npm
  # }}}

  # nvm-completion {{{
  # __nvm_completion() {
  #   unset -f __nvm_completion
  #   complete -r nvm

  #   local -r completion="$NVM_DIR/bash_completion"

  #   # shellcheck disable=SC1090
  #   [ -f "$completion" ] && source "$completion" && return 124
  # }
  # complete -F __nvm_completion nvm
  # }}}

  # proto-completion {{{
  __proto_completion() {
    unset -f __proto_completion
    complete -r proto
    eval "$(proto completions --shell bash)" && return 124
  }
  complete -F __proto_completion proto
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
  type direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
  # }}}

  # proto {{{
  # NOTE: very slow
  # type proto >/dev/null 2>&1 && eval "$(proto activate bash)"
  # NOTE: very slow
  # PROMPT_COMMAND='eval "$(proto activate --export bash)"'
  # }}}

  # nvm {{{
  # NOTE: nvm very slow to start
  # https://github.com/nvm-sh/nvm/issues/2724
  # shellcheck disable=SC1091
  # [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
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

  # git-worktree.bash {{{
  gw() {
    unset -f gw
    # shellcheck disable=SC1091
    source "${GHQ_ROOT:-$HOME/.ghq}/github.com/sasaplus1/git-worktree.bash/git-worktree.bash" 2>/dev/null
    __gw "$@"
  }
  # NOTE: use `eval "$(declare -f gw | sed "1s/gw/${__GW_CMD:-gw}/")"` if $__GW_CMD is set
  # }}}

  # ni.bash {{{
  ni() {
    unset -f ni
    # shellcheck disable=SC1091
    source "${GHQ_ROOT:-$HOME/.ghq}/github.com/sasaplus1/ni.bash/ni.bash" 2>/dev/null
    ni "$@"
  }
  # }}}

  # up {{{
  up() {
    unset -f up
    # shellcheck disable=SC1091
    source "${GHQ_ROOT:-$HOME/.ghq}/github.com/shannonmoeller/up/up.sh" 2>/dev/null
    up "$@"
  }
  # }}}

  # zoxide {{{
  type zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
  # }}}

  # fzf {{{
  for fzf_completion in \
    "$macports_prefix/share/fzf/shell/completion.bash" \
    "$HOMEBREW_PREFIX/opt/fzf/shell/completion.bash"
  do
    # shellcheck disable=SC1090
    [ -r "$fzf_completion" ] && source "$fzf_completion" && break
  done

  local fzf_completion_loaded=
  export __FZF_COMPLETION_LOADED=

  type _fzf_complete >/dev/null 2>&1 &&
    fzf_completion_loaded=1 &&
    __FZF_COMPLETION_LOADED=$fzf_completion_loaded

  readonly fzf_completion_loaded
  readonly __FZF_COMPLETION_LOADED

  # NOTE: Don't override default key bindings
  # local -r fzf_key_bindings=(
  #   'ctrl-alt-b:preview-page-up'
  #   'ctrl-alt-d:preview-half-page-down'
  #   'ctrl-alt-f:preview-page-down'
  #   'ctrl-alt-j:preview-down'
  #   'ctrl-alt-k:preview-up'
  #   'ctrl-alt-u:preview-half-page-up'
  # )

  local -r fzf_options=(
    '--border'
    '--cycle'
    '--height=80%'
    '--info=hidden'
    '--layout=reverse'
    '--preview-window=right'
    # "--bind=$(IFS=,; echo "${fzf_key_bindings[*]}")"
  )

  # https://www.shellcheck.net/wiki/SC2155
  FZF_DEFAULT_OPTS="$(IFS=' '; echo "${fzf_options[*]}")"
  export FZF_DEFAULT_OPTS

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
      # prevent fzf borders from collapsing
      # https://github.com/junegunn/fzf/releases/tag/0.36.0
      # https://twitter.com/hayajo/status/1625846313060548609
      RUNEWIDTH_EASTASIAN=0 command fzf "$position" "$@"
    else
      RUNEWIDTH_EASTASIAN=0 command fzf "$@"
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

  # NOTE: get command name from completion function name
  # _fzf_complete_git
  # local -r command="${FUNCNAME[0]##*_}" # => "git"

  # cd complete by fzf with preview
  _fzf_complete_cd() {
    _fzf_complete --preview='ls -al {}' -- "$@" < \
      <(cat \
            <(fd -t d 2>/dev/null) \
            <(ghq list --full-path 2>/dev/null) \
            <(git worktree list 2>/dev/null | awk '{ print $1 }') \
            <(zoxide query --list 2>/dev/null) \
          )
            # <(git ls-tree -dr --name-only --full-name HEAD ) \
  }
  [ -n "$fzf_completion_loaded" ] && complete -F _fzf_complete_cd -o default -o bashdefault cd

  # docker complete by fzf with preview
  _fzf_complete_docker() {
    local -r command=docker
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
    local -r subcommand="$(__detect_subcommand docker)"

    case "$subcommand" in
      rmi)
        awk '{ print $3 }'
        ;;
      **)
        awk '{ print $1 }'
        ;;
    esac
  }
  [ -n "$fzf_completion_loaded" ] && complete -F _fzf_complete_docker -o default -o bashdefault docker

  # git complete by fzf with preview
  _fzf_complete_git() {
    local -r command=git
    local -r subcommand="$(__detect_subcommand "$command")"

    case "$subcommand" in
      add)
        _fzf_complete --ansi --multi --preview='git diff --color=always {2}' -- "$@" < \
          <(git status --short)
        ;;
      branch)
        _fzf_complete --ansi --multi --preview='git show --color=always {}' -- "$@" < \
          <(git branch --all --format='%(refname:short)')
        ;;
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
      worktree)
        _fzf_complete_git_worktree "$@"
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
      add)
        awk '{ print $2 }' # get by git status
        ;;
      branch)
        awk '{ print $1 }' # get by git branch
        ;;
      checkout|co)
        head -n 1
        ;;
      cherry-pick|cp|rebase)
        grep -Eo '[0-9a-f]{7,40}' | head -n 1 # get by git log
        ;;
      worktree)
        _fzf_complete_git_worktree_post "$@"
        ;;
    esac
  }
  [ -n "$fzf_completion_loaded" ] && complete -F _fzf_complete_git -o default -o bashdefault git

  # git-worktree complete by fzf with preview, called by _fzf_complete_git
  _fzf_complete_git_worktree() {
    local -r command=worktree
    local -r subcommand="$(__detect_subcommand worktree)"

    case "$subcommand" in
      add)
        _fzf_complete --preview='GH_FORCE_TTY=1 gh pr view {1}' -- "$@" < \
          <(gh pr list --json 'number,headRefName,author' --jq '.[] | "#\(.number)\t\(.author.login)\t\(.headRefName)"')
      ;;
      remove)
        # NOTE: { gsub(/[\]\[]/, ""); } is not work
        _fzf_complete -- "$@" < \
          <(git worktree list | awk '{ print $3 }' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | tr -d '[]')
      ;;
      *)
        # call original completion
        _fzf_handle_dynamic_completion git "$command" "$@"
      ;;
    esac
  }
  _fzf_complete_git_worktree_post() {
    local -r subcommand="$(__detect_subcommand worktree)"

    case "$subcommand" in
      add)
        local -r branch="$(awk '{ print $3 }')" # get by gh pr list
        printf -- '"%s" %s' "$(git rev-parse --git-dir)/non-bare-worktrees/$branch" "$branch"
        ;;
      remove)
        cat # get by git worktree list
        ;;
    esac
  }

  # gh complete by fzf with preview
  _fzf_complete_gh() {
    local -r command=gh
    local -r subcommand="$(__detect_subcommand "$command")"

    case "$subcommand" in
      co)
        _fzf_complete --preview="GH_FORCE_TTY=1 gh pr view {1}" -- "$@" < \
          <(gh pr list --json number,title -q '.[] | "#\(.number)\t\(.title)"')
        ;;
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
      [ -n "$__FZF_COMPLETION_LOADED" ] && \
      complete -F _fzf_complete_gh -o default -o bashdefault gh && \
      return 124
  }
  complete -F __gh_completion gh

  # tig complete by fzf with preview
  _fzf_complete_tig() {
    _fzf_complete --preview='git show --color=always {}' -- "$@" < <(git branch --all --format='%(refname:short)')
  }
  [ -n "$fzf_completion_loaded" ] && complete -F _fzf_complete_tig -o default -o bashdefault tig
  # }}}

  # vim {{{
  local -r lvim="$HOME/.local/bin/vim"
  local -r mvim="${GHQ_ROOT:-$HOME/.ghq}/github.com/sasaplus1/macos-vim/usr/bin/vim"

  [ -x "$lvim" ] && export EDITOR="$lvim"
  [ -x "$mvim" ] && export EDITOR="$mvim"

  if [ -n "$VIM_TERMINAL" ]
  then
    # TODO: for Neovim
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
      else
        command vim "$@"
      fi
    }
  fi
  # }}}

  #-----------------------------------------------------------------------------

  # functions and aliases {{{
  rm() {
    # NOTE: this script define within interactive shell only

    if type osascript >/dev/null 2>&1
    then
      # for macOS
      local args=()
      for arg in "$@"
      do
        if [ -d "$arg" ]
        then
          # readlink -f
          args+=("$(cd "$arg" && pwd)")
        elif [ -f "$arg" ]
        then
          # readlink -f
          args+=("$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")")
        fi
      done
      set -x
      # NOTE: rmtrash cannot revert files and directories, osascript does
      osascript - <<-'EOB' "${args[@]}"
			on run argv
			    repeat with i in argv
			        tell application "Finder"
			            move (i as POSIX file) to trash
			        end tell
			    end repeat
			end run
			EOB
      set +x
    elif type trash-put >/dev/null 2>&1
    then
      # for Linux
      set -x
      # NOTE: untested
      trash-put -- "$@"
      set +x
    else
      local -r trash_dir="$HOME/.pseudo_trash"

      command mkdir -p "$trash_dir"

      set -x
      for arg in "$@"
      do
        # success if arg is file or directory
        command mv -- "$arg" "$trash_dir/$arg-$(command date +%Y%m%dT%H%M%S)"
      done
      set +x
    fi
  }

  help() {
    if type bat >/dev/null 2>&1
    then
      command help "$@" | bat -l bash --style=plain --paging=always
    else
      command help "$@"
    fi
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
      repo_cmd='find "${GHQ_ROOT:-$HOME/.ghq}" -mindepth 3 -maxdepth 3 -type d -print'
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

    if type git >/dev/null 2>&1 && [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == 'true' ]
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

  # cd to repository root
  rr() {
    # NOTE: git rev-parse --show-toplevel is cannot execute in .git directory
    # error message print to stderr if failed
    # git rev-parse --is-inside-work-tree >/dev/null && cd "$(git rev-parse --show-toplevel)" || return

    local -r git_common_dir="$(git rev-parse --git-common-dir)"

    if [ "$(git rev-parse --is-inside-git-dir)" == 'true' ]
    then
      # in .git directory
      cd "$git_common_dir/.." || return
    else
      local -r root="$(git rev-parse --show-toplevel)"

      if [ "$root" == "$PWD" ] && [ -f "$root/.git" ]
      then
        # worktree root in .git/non-bare-worktrees
        cd "$git_common_dir/.." || return
      else
        # in worktree
        cd "$root" || return
      fi
    fi
  }

  memo() {
    "$EDITOR" "$HOME/Memo/$(date +%Y%m%dT%H%M%S).md"
  }

  printpath() {
    local -r var="${1:-PATH}"
    local -r path="${!var}"
    echo "${path//:/$'\n'}"
  }

  #-----------------------------------------------------------------------------

  if type tmux >/dev/null 2>&1
  then
    # switch tmux session
    switch-session() {
      tmux switch-client -t "$(tmux list-sessions | fzf --no-multi | awk '{ print $1 }')"
    }

    # reorder tmux session
    reorder-session() {
      # without popup session
      tmux list-sessions -F#S | grep -v popup | awk '{ if ($0 != NR - 1) print $0, NR - 1 }' | xargs -n 2 tmux rename -t
    }

    # popup tmux session
    # based on https://zenn.dev/skanehira/articles/2020-10-25-tmux-toggle-popup
    popup-session() {
      local width=90%
      local height=90%
      local session
      session="$(tmux display-message -p -F "#{session_name}")"

      if [[ "$session" == *popup* ]]
      then
        tmux detach-client
      else
        tmux popup -d '#{pane_current_path}' -xC -yC -w"$width" -h"$height" -E 'tmux attach -t popup || tmux new -s popup'
      fi
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
    local origin_head_file=

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

      # vcs info
      #     $ vcprompt -f '%n:%b:%r' 2>/dev/null
      # is too slow
      #     $ git rev-parse --is-inside-work-tree
      # too

      # git-worktree or git-submodule
      # maybe read is faster than awk
      # https://qiita.com/hasegit/items/5be056d67347e1553f08
      if [ -f "${cwd}/.git" ]
      then
        is_git=1

        local original_head_dir=
        read -r _ original_head_dir < "${cwd}/.git"

        [[ "$original_head_dir" =~ ^\.\.?\/ ]] &&
          # maybe original_head_dir is relative path
          head_dir="${cwd}/${original_head_dir}" ||
          # maybe original_head_dir is absolute path
          head_dir="$original_head_dir"

        head_file="${head_dir}/HEAD"

        [[ "$head_file" =~ \.git\/worktrees ]] &&
          repo_type=git-worktree ||
          repo_type=git-submodule

        if [ -f "${head_dir}/commondir" ]
        then
          # git-worktree has commondir file
          local commondir=
          read -r commondir < "${head_dir}/commondir"
          origin_head_file="${head_dir}/${commondir}/refs/remotes/origin/HEAD"
        else
          # git-submodule hasnot commondir file
          origin_head_file="${head_dir}/refs/remotes/origin/HEAD"
        fi
      fi

      # git repository
      if [ -d "${cwd}/.git" ]
      then
        is_git=1

        repo_type=git
        head_file="${cwd}/.git/HEAD"
        origin_head_file="${cwd}/.git/refs/remotes/origin/HEAD"
      fi

      # get refs
      if [ -n "$head_file" ]
      then
        local col1=
        local col2=

        read -r col1 col2 < "$head_file"

        if [ "$col1" == 'ref:' ]
        then
          refs=${col2/#refs\/heads\//}
        else
          is_hash=1
          refs=${col1::7}
        fi
      fi

      # get origin's default branch name
      if [ -f "$origin_head_file" ]
      then
        read -r _ default_branch < "$origin_head_file"
        default_branch="${default_branch#refs/remotes/origin/}"
      fi

      # break if git repository found
      [ -n "$repo_type" ] && break

      cwd="$(cd "${cwd}/.." && pwd)"
    done

    local prompt=

    # architecture
    # `uname -m` prints `x86_64` when `arch -x86_64 /bin/bash` executed
    # NOTE: `uname -m` is cannot cache
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

  __print_ps1() {
    local -r green='\e[01;32m'
    local -r reset='\e[00m'

     # NOTE: need double escape because bash says `missing unicode digit for \u`
    local -r u='\\u'

    # /current/dir error (git:branch or revision) (yarn:lerna) (vim)
    # username@hostname$ _
    printf -- '%b' "${green}\w${reset}\$(__print_status \$?)\n${u}@\h$ "
  }

  # ssh-agent
  __show_ssh_agent() {
    if [[ "$SSH_AUTH_SOCK" == *bitwarden* ]]
    then
      echo '[ssh:bitwarden] '
    fi
  }
  export -f __show_ssh_agent

  # direnv with virtualenv
  __show_virtual_env() {
    if [ -n "$VIRTUAL_ENV" ] && [ -n "$DIRENV_DIR" ]
    then
      echo "($(basename "$VIRTUAL_ENV")) "
    fi
  }
  export -f __show_virtual_env

  # NOTE: SC2155
  # https://github.com/koalaman/shellcheck/wiki/SC2155
  PS1=$(__print_ps1)
  PS1='$(__show_ssh_agent)$(__show_virtual_env)'$PS1
  export PS1
  # }}}

  alias gt='git'
  alias gti='git'
  alias igt='git'

  if [ -n "$apple_silicon" ]
  then
    alias armsh='arch -arm64e /bin/bash'
    alias x86sh='arch -x86_64 /bin/bash'
  fi

  case "$os" in
    macos)
      ls() {
        # new macOS ls has --color option
        command ls --color "$@" || command ls -G "$@"
      }
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

  # return if terminal multiplexer used
  [[ "$TERM" =~ ^(screen|tmux) ]] && return 0

  # return if coding agent
  [ -n "$CLAUDECODE" ] && return 0
  [ -n "$CURSOR_AGENT" ] && return 0

  # always use terminal multiplexer
  if [ -z "$TMUX" ] && [ -z "$VIM_TERMINAL" ] && [ ! -f '/.dockerenv' ] && type tmux >/dev/null 2>&1
  then
    if [ -n "$COLORTERM" ]
    then
      command tmux new-session -e "COLORTERM=${COLORTERM}"
    else
      env -u COLORTERM command tmux new-session
    fi
  fi
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
