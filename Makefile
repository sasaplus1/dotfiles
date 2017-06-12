# set default target
.DEFAULT_GOAL := all

# change to use Bash
SHELL := /bin/bash

#-------------------------------------------------------------------------------

# NOTE: need synchronize to .bashrc

# Homebrew and Homebrew Cask directories
homebrew_dir := $(HOME)/Homebrew
caskroom_dir := $(HOME)/Caskroom

# dotfiles directory
dotfiles_dir := $(HOME)/.ghq/github.com/sasaplus1/dotfiles

# use installed brew
export PATH := $(homebrew_dir)/bin:$(PATH)

#-------------------------------------------------------------------------------

# get lowercased os name
os := $(shell uname -s | tr 'A-Z' 'a-z')

# flag of when execute in CI
ci := $(CI)

# skip-tags of Ansible
skip_tags := $(SKIP_TAGS)

#-------------------------------------------------------------------------------

# default target
.PHONY: all
all:
	@echo 'targets:'
	@echo '  all               show this messages'
	@echo '  setup             setup my environment'
	@echo ''
	@echo 'subtargets:'
	@echo '  pre-setup-darwin  install bootstrapping for OS X'
	@echo '  pre-setup-linux   install bootstrapping for Debian family'
	@echo '  install-brew      install Homebrew/Linuxbrew'
	@echo '  clone             clone dotfiles repository'
	@echo '  provision         execute ansible-playbook'

# setup my environment
.PHONY: setup
setup: pre-setup-$(os) clone provision

#-------------------------------------------------------------------------------

# pre-setup for OS X
.PHONY: pre-setup-darwin
pre-setup-darwin: install-brew
pre-setup-darwin:
	brew update
	brew install ansible git

#-------------------------------------------------------------------------------

# pre-setup for Debian family
.PHONY: pre-setup-linux
pre-setup-linux: install-brew
pre-setup-linux:
	sudo add-apt-repository --yes ppa:ansible/ansible
	sudo apt-get update -qq
	sudo apt-get install -qq --yes ansible git

#-------------------------------------------------------------------------------

define __install_brew_script
  case '$(os)' in
    darwin)
      tarball=https://github.com/Homebrew/homebrew/tarball/master
      ;;
    linux)
      tarball=https://github.com/Linuxbrew/brew/tarball/master
      ;;
    *)
      echo 'brew is not supported for this platform.' 1>&2
      exit 1
      ;;
  esac

  if [ -e '$(homebrew_dir)/bin/brew' ]
  then
    echo "Homebrew/Linuxbrew is already installed."
  else
    mkdir -p '$(homebrew_dir)'
    curl -fsSL $$tarball | tar xz --strip 1 -C '$(homebrew_dir)'
  fi
endef
export __install_brew_script

# install Homebrew/Linuxbrew
.PHONY: install-brew
install-brew:
	$(SHELL) -x -c "$$__install_brew_script"

#-------------------------------------------------------------------------------

define __clone_script
  if [ -d '$(dotfiles_dir)/.git' ]
  then
    echo 'dotfiles repository is already cloned.'
  else
    if [ -n "$$TRAVIS_BRANCH" ]
    then
      branch=$$TRAVIS_BRANCH
    else
      branch=master
    fi

    git clone --branch="$$branch" $(repository) '$(dotfiles_dir)'
  fi
endef
export __clone_script

# clone dotfiles repository
.PHONY: clone
clone: repository := https://github.com/sasaplus1/dotfiles.git
clone:
	$(SHELL) -c "$$__clone_script"

#-------------------------------------------------------------------------------

# execute provision
.PHONY: provision
provision: options :=
provision: options += --inventory-file=<(printf -- 127.0.0.1),
provision: options += --extra-vars='homebrew_dir=$(homebrew_dir)'
provision: options += --extra-vars='caskroom_dir=$(caskroom_dir)'
provision: options += --extra-vars='dotfiles_dir=$(dotfiles_dir)'
provision: options += --extra-vars='home_dir=$(HOME)'
ifdef skip_tags
provision: options += --skip-tags='$(skip_tags)'
endif
provision: options += --connection=local
ifndef ci
provision: options += --ask-become-pass
provision: options += -vv
endif
provision: playbook := '$(dotfiles_dir)/ansible/site.yml'
provision:
	ansible-playbook $(options) $(playbook)
