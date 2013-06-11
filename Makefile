#!/usr/bin/make -f

copy_files = \
  .curlrc \
  .npmrc \
  .vimrc.local \
  .wgetrc

symlink_files = \
  .bash_logout \
  .bash_profile \
  .bashrc \
  .gitconfig \
  .gemrc \
  .gvimrc \
  .hgrc \
  .screenrc \
  .tigrc \
  .tmux.conf \
  .vimrc

touch_files = \
  .bashrc.local \
  .gitconfig.local \
  .hgrc.local

all_file_paths = $(sort \
  $(foreach \
    file, \
    $(copy_files) $(symlink_files) $(touch_files), \
    $(addprefix $$HOME/,$(file)) \
  ) \
)

copy_file_paths = $(sort \
  $(foreach \
    file, \
    $(copy_files), \
    $(addprefix $(CURDIR)/*/,$(file)) \
  ) \
)

symlink_file_paths = $(sort \
  $(foreach \
    file, \
    $(symlink_files), \
    $(addprefix $(CURDIR)/*/,$(file)) \
  ) \
)

touch_file_paths = $(sort \
  $(foreach \
    file, \
    $(touch_files), \
    $(addprefix $$HOME/,$(file)) \
  ) \
)

ifeq ($(wildcard $(CURDIR)/.git),)
  $(error This Makefile must be execute in dotfiles dir)
endif

.DEFAULT_GOAL := all

.PHONY: all
all:
	@echo 'targets:'
	@echo '  all      show this message'
	@echo '  clean    remove copied files, symlinks and touched files'
	@echo '  setup    copy files, make symlinks and touch files'

.PHONY: setup
setup: copy symlink touch

.PHONY: clean
clean:
	@$(RM) $(all_file_paths)

.PHONY: copy
copy:
	-@ls -1 $(copy_file_paths) | xargs -I {} cp "{}" "$$HOME/{}"

.PHONY: symlink
symlink:
	-@ls -1 $(symlink_file_paths) | xargs -I {} ln -s "{}" "$$HOME/{}"

.PHONY: touch
touch:
	-@ls -1 $(touch_file_paths) | xargs -I {} touch "$$HOME/{}"
