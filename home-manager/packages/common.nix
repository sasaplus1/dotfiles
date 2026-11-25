{ pkgs, pkgs-unstable, lib }:
[
  pkgs.age
  pkgs.bash
  pkgs.bash-completion
  pkgs.bash-preexec
  pkgs.bat
  pkgs.curl
  pkgs.delta
  pkgs.direnv
  ### pkgs-unstable.docker-sbx
  pkgs.fac
  pkgs.fd
  pkgs.ffmpeg-headless
  pkgs.fswatch
  pkgs.fzf
  # gh is managed by programs.gh in home.nix to install its extensions together.
  pkgs.ghq
  pkgs.gibo
  pkgs-unstable.git
  pkgs.git-crypt
  pkgs.git-filter-repo
  pkgs.gnupg
  pkgs.glow
  pkgs.gron
  pkgs.jq
  pkgs-unstable.mise
  pkgs.mmv-go
  pkgs.nmap
  pkgs.ripgrep
  pkgs.rsync
  pkgs.sops
  pkgs.tig
  pkgs.tmux
  pkgs.transcrypt
  pkgs.vifm
  pkgs.vim-full
  pkgs.yq-go
  pkgs.zoxide
] ++ lib.optionals pkgs.stdenv.isDarwin [
  pkgs.mas
] ++ lib.optionals pkgs.stdenv.isLinux [
  pkgs.trash-cli
  pkgs.xsel
]
