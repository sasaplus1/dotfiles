.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

os := $(subst darwin,macos,$(shell uname -s | tr 'A-Z' 'a-z'))

#-------------------------------------------------------------------------------

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: build
build: ## build without activating (dry run)
	home-manager build --flake ".#$${USER}" --impure

.PHONY: clean
clean: ## collect garbage (keep recent 30 days)
	nix-collect-garbage --delete-older-than 30d

.PHONY: deep-clean
deep-clean: ## collect garbage (delete ALL old generations)
	nix-collect-garbage -d

.PHONY: generations
generations: ## list home-manager generations
	home-manager generations

.PHONY: install-home-manager
install-home-manager: ## install home-manager CLI
	nix profile install nixpkgs#home-manager

.PHONY: install
install: ## install Nix
install: install-nix-$(os)

.PHONY: install-nix-macos
install-nix-macos: ## [subtarget] install Nix for macOS (Determinate Nix)
	curl -fsSL https://install.determinate.systems/nix | sh -s -- install

.PHONY: install-nix-linux
install-nix-linux: ## [subtarget] install Nix for Linux (official installer)
	curl -fsSL https://nixos.org/nix/install | sh

.PHONY: switch
switch: ## switch home-manager configuration
	home-manager switch --flake ".#$${USER}" --impure

.PHONY: update
update: ## update flake inputs
	nix flake update
