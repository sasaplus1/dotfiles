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
build: ## build common profile without activating (dry run)
	home-manager build --flake ".#common" --impure

.PHONY: build-extra
build-extra: ## build extra profile without activating (dry run)
	home-manager build --flake ".#extra" --impure

.PHONY: build-music
build-music: ## build music profile without activating (dry run)
	home-manager build --flake ".#music" --impure

.PHONY: build-full
build-full: ## build full profile without activating (dry run)
	home-manager build --flake ".#full" --impure

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
	nix profile add nixpkgs#home-manager

.PHONY: install
install: ## install Nix
install: install-nix-$(os)

.PHONY: install-nix-macos
install-nix-macos: ## [subtarget] install Nix for macOS (NixOS/nix-installer with flakes)
	curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes

.PHONY: install-nix-linux
install-nix-linux: ## [subtarget] install Nix for Linux (NixOS/nix-installer with flakes)
	curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes

.PHONY: switch
switch: ## switch to common profile (default)
	home-manager switch --flake ".#common" --impure

.PHONY: switch-extra
switch-extra: ## switch to extra profile
	home-manager switch --flake ".#extra" --impure

.PHONY: switch-music
switch-music: ## switch to music profile
	home-manager switch --flake ".#music" --impure

.PHONY: switch-full
switch-full: ## switch to full profile
	home-manager switch --flake ".#full" --impure

.PHONY: update
update: ## update flake inputs
	nix flake update
