.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

# destination directory
dest ?= $(HOME)

dotfile_dirs := $(abspath $(strip \
  $(dest)/.chrome-local-overrides \
  $(dest)/.cocproxy \
  $(dest)/.config \
  $(dest)/.config/alacritty \
  $(dest)/.config/git \
  $(dest)/.config/nvim \
  $(dest)/.config/ranger \
  $(dest)/.ghq \
  $(dest)/.go \
  $(dest)/.go/bin \
  $(dest)/.go/pkg \
  $(dest)/.go/src \
  $(dest)/.nodebrew \
  $(dest)/.peco \
  $(dest)/.rbenv \
  $(dest)/.ssh \
  $(dest)/.urxvt \
  $(dest)/.vim \
  $(dest)/.vim/backup \
  $(dest)/.vim/swap \
  $(dest)/.vim/undo \
))

symlinks := $(abspath $(strip \
  $(makefile_dir)/X11/.Xdefaults             $(dest)/.Xdefaults \
  $(makefile_dir)/alacritty/alacritty.yml    $(dest)/.config/alacritty/alacritty.yml \
  $(makefile_dir)/bash/.bash_logout          $(dest)/.bash_logout \
  $(makefile_dir)/bash/.bash_profile         $(dest)/.bash_profile \
  $(makefile_dir)/bash/.bashrc               $(dest)/.bashrc \
  $(makefile_dir)/ctags/.ctags               $(dest)/.ctags \
  $(makefile_dir)/ctags/.ctagsignore         $(dest)/.ctagsignore \
  $(makefile_dir)/git/.gitconfig             $(dest)/.gitconfig \
  $(makefile_dir)/git/.gitignore             $(dest)/.config/git/ignore \
  $(makefile_dir)/locate/.locate.rc          $(dest)/.locate.rc \
  $(makefile_dir)/mercurial/.hgrc            $(dest)/.hgrc \
  $(makefile_dir)/nginx/.cocproxy.nginx.conf $(dest)/.cocproxy.nginx.conf \
  $(makefile_dir)/pt/.ptignore               $(dest)/.ptignore \
  $(makefile_dir)/peco/config.json           $(dest)/.peco/config.json \
  $(makefile_dir)/ranger/commands.py         $(dest)/.config/ranger/commands.py \
  $(makefile_dir)/ranger/rc.conf             $(dest)/.config/ranger/rc.conf \
  $(makefile_dir)/ruby/.gemrc                $(dest)/.gemrc \
  $(makefile_dir)/screen/.screenrc           $(dest)/.screenrc \
  $(makefile_dir)/slate/.slate               $(dest)/.slate \
  $(makefile_dir)/tern/.tern-project         $(dest)/.tern-project \
  $(makefile_dir)/tig/.tigrc                 $(dest)/.tigrc \
  $(makefile_dir)/tmux/.tmux.conf            $(dest)/.tmux.conf \
  $(makefile_dir)/vim/coc-settings.json      $(dest)/.vim/coc-settings.json \
  $(makefile_dir)/vim/.gvimrc                $(dest)/.gvimrc \
  $(makefile_dir)/vim/.vimrc                 $(dest)/.vimrc \
  $(makefile_dir)/vim/.vimrc                 $(dest)/.config/nvim/init.vim \
))

copy_targets := $(abspath $(strip \
  $(makefile_dir)/curl/.curlrc      $(dest)/.curlrc \
  $(makefile_dir)/node.js/.npmrc    $(dest)/.npmrc \
  $(makefile_dir)/ruby/default-gems $(dest)/.rbenv/default-gems \
  $(makefile_dir)/vim/.vimrc.local  $(dest)/.vimrc.local \
  $(makefile_dir)/wget/.wgetrc      $(dest)/.wgetrc \
))

create_targets := $(abspath $(strip \
  $(dest)/.bash_logout.local \
  $(dest)/.bashrc.local \
  $(dest)/.gitconfig.local \
  $(dest)/.hgrc.local \
))

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: deploy
deploy: ## deploy dotfiles
	-@printf -- '%s\n' $(dotfile_dirs)   | xargs -n 1 bash -c 'mkdir -pv "$$0"'
	-@printf -- '%s\n' $(symlinks)       | xargs -n 2 bash -c 'ln -sv "$$0" "$$1"'
	-@printf -- '%s\n' $(copy_targets)   | xargs -n 2 bash -c 'cp -nv "$$0" "$$1"'
	-@printf -- '%s\n' $(create_targets) | xargs -n 1 bash -c 'cp -nv <(echo -n) "$$0"'
	@echo 'done.'

.PHONY: lint
lint: shells := $(addprefix bash/,.bash_logout .bash_profile .bashrc)
lint: vimrcs := $(addprefix vim/,.vimrc .vimrc.autocmd .vimrc.config .vimrc.local .vimrc.map .vimrc.plugin .vimrc.root)
lint: ## lint some scripts
	-@docker-compose run --rm shellcheck $(shells)
	-@docker-compose run --rm vint $(vimrcs)

.PHONY: test
test: ## check deployed files
	@printf -- '%s\n' $(dotfile_dirs)   | xargs -n 1 bash -c '[ -d "$$0" ] || echo "$$0 is not found"'
	@printf -- '%s\n' $(symlinks)       | xargs -n 2 bash -c '[ -L "$$1" ] || echo "$$1 is not found"'
	@printf -- '%s\n' $(copy_targets)   | xargs -n 2 bash -c '[ -f "$$1" ] || echo "$$1 is not found"'
	@printf -- '%s\n' $(create_targets) | xargs -n 1 bash -c '[ -f "$$0" ] || echo "$$0 is not found"'
	@echo 'done.'

.PHONY: vars
vars: ## print variables
	@$(MAKE) -f $(makefile) -prR | grep '^# makefile' -A 1
