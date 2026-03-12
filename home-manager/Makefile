.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

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

.PHONY: switch
switch: ## switch home-manager configuration
	home-manager switch --flake ".#$${USER}" --impure

.PHONY: update
update: ## update flake inputs
	nix flake update
