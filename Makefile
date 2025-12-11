.PHONY: commit host_check switch boot test upgrade clean help
.DEFAULT_GOAL := help

# Variables
COMMIT_MSG ?= "Update configuration"
TARGET_HOST ?= $(shell hostname)
BUILD_ARGS ?= --flake .\#$(TARGET_HOST)
GIT_REMOTE ?= server

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

commit: *.nix
ifndef COMMIT_MSG
	$(error COMMIT_MSG is required. Usage: make switch COMMIT_MSG="your commit message")
endif
	@echo -e "$(YELLOW)Switching NixOS configuration...$(NC)\n"
	@git add .
	@if git commit -m $(COMMIT_MSG) && git push $(GIT_REMOTE) main; then \
		echo -e "$(GREEN)Git commit and push successful$(NC)"; \
	else \
		echo -e "$(Yellow)No changes to commit or push failed$(NC)"; \
	fi

host_check:
ifneq (${TARGET_HOST}, $(shell hostname))
	$(warning TARGET_HOST (${TARGET_HOST}) does not match the current hostname ($(shell hostname))). 
	@read -p "Proceed? (y/n): " PROCEED; if [ $${PROCEED:-"N"} != "y" && "$${PROCEED:-"N"}" != "Y" ]; then \
		echo -e "$(RED)Aborting switch due to hostname mismatch$(NC)"; \
		exit 1; \
	fi
endif

switch: commit host_check ## Commit changes, push to origin, and rebuild NixOS system
	@nixos-rebuild switch $(BUILD_ARGS) --sudo

boot: commit host_check ## Commit changes, push to origin, and rebuild NixOS system with bootloader update
	@nixos-rebuild boot $(BUILD_ARGS) --sudo

upgrade: commit host_check## Upgrade NixOS system and all packages
	@echo -e "$(YELLOW)Upgrading NixOS system and packages...$(NC)\n"
	@nixos-rebuild switch $BUILD_ARGS --upgrade --sudo

test: commit host_check ## Build and test NixOS configuration
	@echo -e "$(YELLOW)Testing NixOS configuration for host: $(TARGET_HOST)$(NC)\n"
	@nixos-rebuild test $(BUILD_ARGS) --show-trace
		 
test-vm: ## Build and run NixOS VM for testing (optionally specify TARGET_HOST)
	@echo -e "$(YELLOW)Building VM for host: $(TARGET_HOST)$(NC)\n"
	@if nixos-rebuild build-vm $(BUILD_ARGS) --show-trace; then \
		echo -e "$(GREEN)Build successful. Starting VM...$(NC)"; \
		result/bin/run-$(TARGET_HOST)-vm; \
	else \
		echo -e "$(RED) Build failed. Skipping VM start.$(NC)"; \
		exit 1; \
	fi

dry-run: ## Perform a dry run of the NixOS configuration switch
	@echo -e "$(YELLOW)Performing dry run for NixOS configuration switch...$(NC)\n"
	@git diff
	@if nixos-rebuild dry-run $(BUILD_ARGS); then \
		echo -e "$(GREEN)Dry run complete - no changes were made$(NC)"; \
	fi

clean: ## Remove build artifacts
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)\n"
	@if [ -D result ]; then \
		rm -rf result; \
		rm -f *.qcow2; \
		echo -e "$(GREEN)Removed result symlink$(NC)"; \
	fi