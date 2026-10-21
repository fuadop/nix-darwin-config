SHELL := /bin/bash
.DEFAULT_GOAL := refresh

NIX_PATH := $(shell command -v nix)
BREW_PATH := /opt/homebrew/bin/brew
XDG_CONFIG_HOME := $(HOME)/.config
PLAYGROUND_PATH := $(HOME)/Documents/playground
DOTFILES_GIT_PATH := $(PLAYGROUND_PATH)/dotfiles


.PHONY: init
init:
	@if [ -z "$(NIX_PATH)" ]; then \
		curl -L https://nixos.org/nix/install | sh; \
	fi
	@if [ ! -f "$(BREW_PATH)" ]; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@if [ ! -d "$(PLAYGROUND_PATH)" ]; then \
		mkdir -p "$(PLAYGROUND_PATH)"; \
	fi
	@if [ ! -d "$(XDG_CONFIG_HOME)" ]; then \
		mkdir -p "$(XDG_CONFIG_HOME)"; \
	fi
	@if [ -z "$(GIT_PAT_TOKEN)" ]; then \
		echo 'run make with GIT_PAT_TOKEN=xxx to clone dotfiles. make init GIT_PAT_TOKEN=xxx'; \
	else \
		git clone "https://$(GIT_PAT_TOKEN)@github.com/fuadop/dotfiles.git" "$(DOTFILES_GIT_PATH)"; \
	fi

refresh:
	sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#pc
	cd $(DOTFILES_GIT_PATH) && \
		nix-shell -p stow --run 'make install'
