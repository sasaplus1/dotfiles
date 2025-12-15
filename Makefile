.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

os := $(subst darwin,macos,$(shell uname -s | tr 'A-Z' 'a-z'))

# destination directory
dest ?= $(HOME)

#-------------------------------------------------------------------------------

# dotfile directories {{{

dotfile_dirs :=
ifeq ($(os),macos)
# NOTE: + is space, because GNU Make cannot handle spaces
# see: https://please-sleep.cou929.nu/gnu-make-spaces-in-pathname.html
# see: https://savannah.gnu.org/bugs/index.php?712
# see: https://m-hiyama.hatenablog.com/entry/20140920/1411186147
dotfile_dirs += $(dest)/Memo
dotfile_dirs += $(dest)/Library
dotfile_dirs += $(dest)/Library/Application+Support
dotfile_dirs += $(dest)/Library/Application+Support/Code
dotfile_dirs += $(dest)/Library/Application+Support/Code/User
endif
dotfile_dirs += $(dest)/.chrome-local-overrides
dotfile_dirs += $(dest)/.cocproxy
dotfile_dirs += $(dest)/.config
ifeq ($(os),linux)
dotfile_dirs += $(dest)/.config/Code
dotfile_dirs += $(dest)/.config/Code/User
endif
dotfile_dirs += $(dest)/.config/alacritty
dotfile_dirs += $(dest)/.config/aquaproj-aqua
dotfile_dirs += $(dest)/.config/direnv
dotfile_dirs += $(dest)/.config/direnv/lib
dotfile_dirs += $(dest)/.config/gh-dash
dotfile_dirs += $(dest)/.config/ghostty
dotfile_dirs += $(dest)/.config/git
dotfile_dirs += $(dest)/.config/git/hooks
dotfile_dirs += $(dest)/.config/nvim
# dotfile_dirs += $(dest)/.config/ranger
dotfile_dirs += $(dest)/.config/vifm
dotfile_dirs += $(dest)/.ctags.d
dotfile_dirs += $(dest)/.docker
dotfile_dirs += $(dest)/.ghq
dotfile_dirs += $(dest)/.go
dotfile_dirs += $(dest)/.go/bin
dotfile_dirs += $(dest)/.go/pkg
dotfile_dirs += $(dest)/.go/src
dotfile_dirs += $(dest)/.local
# dotfile_dirs += $(dest)/.nodebrew
# dotfile_dirs += $(dest)/.peco
dotfile_dirs += $(dest)/.pseudo_trash
# dotfile_dirs += $(dest)/.rbenv
dotfile_dirs += $(dest)/.ssh
dotfile_dirs += $(dest)/.ssh/sockets
ifeq ($(os),linux)
dotfile_dirs += $(dest)/.urxvt
endif
dotfile_dirs += $(dest)/.vim
dotfile_dirs += $(dest)/.vim/backup
dotfile_dirs += $(dest)/.vim/swap
dotfile_dirs += $(dest)/.vim/undo

dotfile_dirs := $(subst +,\\\ ,$(abspath $(strip $(dotfile_dirs))))

# }}}

# symlinks {{{

symlinks :=
ifeq ($(os),macos)
symlinks += $(makefile_dir)/vscode/settings.json $(dest)/Library/Application+Support/Code/User/settings.json
endif
ifeq ($(os),linux)
symlinks += $(makefile_dir)/vscode/settings.json $(dest)/.config/Code/User/settings.json
symlinks += $(makefile_dir)/xdg/user-dirs.dirs $(dest)/.config/user-dirs.dirs
symlinks += $(makefile_dir)/X11/.Xdefaults $(dest)/.Xdefaults
endif
symlinks += $(makefile_dir)/alacritty/alacritty.toml $(dest)/.config/alacritty/alacritty.toml
symlinks += $(makefile_dir)/aqua/aqua.yaml $(dest)/.config/aquaproj-aqua/aqua.yaml
symlinks += $(makefile_dir)/bash/.bash_logout $(dest)/.bash_logout
symlinks += $(makefile_dir)/bash/.bash_profile $(dest)/.bash_profile
symlinks += $(makefile_dir)/bash/.bashrc $(dest)/.bashrc
symlinks += $(makefile_dir)/bash/.profile $(dest)/.profile
symlinks += $(makefile_dir)/bash/.sh_path $(dest)/.sh_path
# symlinks += $(makefile_dir)/ctags/.ctags $(dest)/.ctags
# symlinks += $(makefile_dir)/ctags/.ctagsignore $(dest)/.ctagsignore
symlinks += $(makefile_dir)/direnv/lib/layout_uv.sh $(dest)/.config/direnv/lib/layout_uv.sh
symlinks += $(makefile_dir)/gh-dash/config.yml $(dest)/.config/gh-dash/config.yml
symlinks += $(makefile_dir)/ghostty/config $(dest)/.config/ghostty/config
symlinks += $(makefile_dir)/git/.gitconfig $(dest)/.gitconfig
symlinks += $(makefile_dir)/git/.gitignore $(dest)/.config/git/ignore
symlinks += $(makefile_dir)/git/hooks/multiple-hooks.sh $(dest)/.config/git/hooks/multiple-hooks.sh
symlinks += $(makefile_dir)/git/hooks/pre-commit $(dest)/.config/git/hooks/pre-commit
# symlinks += $(makefile_dir)/locate/.locate.rc $(dest)/.locate.rc
# symlinks += $(makefile_dir)/mercurial/.hgrc $(dest)/.hgrc
symlinks += $(makefile_dir)/nginx/.cocproxy.nginx.conf $(dest)/.cocproxy.nginx.conf
# symlinks += $(makefile_dir)/pt/.ptignore $(dest)/.ptignore
# symlinks += $(makefile_dir)/peco/config.json $(dest)/.peco/config.json
symlinks += $(makefile_dir)/proto/.prototools $(dest)/.prototools
# symlinks += $(makefile_dir)/ranger/commands.py $(dest)/.config/ranger/commands.py
# symlinks += $(makefile_dir)/ranger/rc.conf $(dest)/.config/ranger/rc.conf
# symlinks += $(makefile_dir)/ruby/.gemrc $(dest)/.gemrc
symlinks += $(makefile_dir)/screen/.screenrc $(dest)/.screenrc
# symlinks += $(makefile_dir)/slate/.slate $(dest)/.slate
symlinks += $(makefile_dir)/sshconfig/config $(dest)/.ssh/config
# symlinks += $(makefile_dir)/tern/.tern-project $(dest)/.tern-project
symlinks += $(makefile_dir)/tig/.tigrc $(dest)/.tigrc
symlinks += $(makefile_dir)/tmux/.tmux.conf $(dest)/.tmux.conf
symlinks += $(makefile_dir)/universal-ctags/main.ctags $(dest)/.ctags.d/main.ctags
symlinks += $(makefile_dir)/vifm/vifmrc $(dest)/.config/vifm/vifmrc
# symlinks += $(makefile_dir)/vim/.gvimrc $(dest)/.gvimrc
symlinks += $(makefile_dir)/vim/.vimrc $(dest)/.vimrc
symlinks += $(makefile_dir)/vim/.vimrc $(dest)/.config/nvim/init.vim
symlinks += $(makefile_dir)/wezterm/.wezterm.lua $(dest)/.wezterm.lua

symlinks := $(subst +,\\\ ,$(abspath $(strip $(symlinks))))

# }}}

# static files {{{

copy_targets :=
copy_targets += $(makefile_dir)/curl/.curlrc $(dest)/.curlrc
copy_targets += $(makefile_dir)/docker/config.json $(dest)/.docker/config.json
copy_targets += $(makefile_dir)/node.js/.npmrc $(dest)/.npmrc
# copy_targets += $(makefile_dir)/ruby/default-gems $(dest)/.rbenv/default-gems
copy_targets += $(makefile_dir)/vim/.vimrc.local $(dest)/.vimrc.local
copy_targets += $(makefile_dir)/wget/.wgetrc $(dest)/.wgetrc

copy_targets := $(abspath $(strip $(copy_targets)))

# }}}

#-------------------------------------------------------------------------------

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: deploy
deploy: ## deploy dotfiles
	-@printf -- '%s\n' $(dotfile_dirs) | xargs -n 1 bash -c 'mkdir -pv "$$0"'
	-@printf -- '%s\n' $(symlinks)     | xargs -n 2 bash -c 'ln -sv "$$0" "$$1"'
	-@printf -- '%s\n' $(copy_targets) | xargs -n 2 bash -c 'cp -nv "$$0" "$$1"'
	@chmod 0700 $(dest)/.ssh $(dest)/.ssh/sockets
	@echo 'done.'

.PHONY: test
test: ## check deployed files
	@printf -- '%s\n' $(dotfile_dirs) | xargs -n 1 bash -c '[ -d "$$0" ] || echo "$$0 is not found"'
	@printf -- '%s\n' $(symlinks)     | xargs -n 2 bash -c '[ -L "$$1" ] || echo "$$1 is not found"'
	@printf -- '%s\n' $(copy_targets) | xargs -n 2 bash -c '[ -f "$$1" ] || echo "$$1 is not found"'
	@echo 'done.'

.PHONY: vars
vars: ## print variables
	@$(MAKE) -f $(makefile) -prR | grep '^# makefile' -A 1
