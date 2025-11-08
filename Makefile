.PHONY: switch test dry-run clean help organize-vms
.DEFAULT_GOAL := help

# Variables
COMMIT_MSG ?= "Update configuration"
TARGET_HOST ?= $(shell hostname)
TEST_DIR ?= test

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {@echo -e "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

switch: ## Commit changes, push to origin, and rebuild NixOS system
ifndef COMMIT_MSG
	$(error COMMIT_MSG is required. Usage: make switch COMMIT_MSG="your commit message")
endif
ifneq ($(TARGET_HOST),$(shell hostname))
	$(warning TARGET_HOST does not match the current hostname. Current hostname is '$(shell hostname)'. Usage: make switch TARGET_HOST="$(shell hostname)" COMMIT_MSG="your commit message")
	PROCEED := $(shell read -p "Proceed? (y/n): " ans; if [ $$ans = "y" ]; then echo -e "yes"; else echo -e "no"; fi)
	ifneq ($(PROCEED), "yes"); then \
		$(error Aborting switch due to hostname mismatch) \
	endif
endif
	@echo -e "$(YELLOW)Switching NixOS configuration...$(NC)\n"
	## git add .
	git commit -a -m $(COMMIT_MSG)
	git push origin main
	nixos-rebuild switch --flake .\#$(TARGET_HOST) --sudo

upgrade: ## Upgrade NixOS system and all packages
	@echo -e "$(YELLOW)Upgrading NixOS system and packages...$(NC)\n"
	nixos-rebuild switch --flake .\#$(TARGET_HOST) --upgrade --sudo

test: ## Build and run NixOS VM for testing (optionally specify TARGET_HOST)
	@echo -e "$(YELLOW)Building VM for host: $(TARGET_HOST)$(NC)\n"
	@cd $(TEST_DIR)
	@if nixos-rebuild build-vm --show-trace --flake .\#$(TARGET_HOST); then \
		echo -e "$(GREEN)Build successful. Starting VM...$(NC)"; \
		result/bin/run-$(TARGET_HOST)-vm; \
	else \
		echo -e "$(RED)Build failed. Skipping VM start.$(NC)"; \
		exit 1; \
	fi

dry-run: 
	@echo -e "$(YELLOW)Performing dry run for NixOS configuration switch...$(NC)\n"
	git diff
	ifeq ($(nixos-rebuild switch --flake .\#$(TARGET_HOST) --dry-run),0)
		echo -e "$(GREEN)Dry run complete - no changes were made$(NC)"
	endif

clean: ## Remove build artifacts
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)\n"
	@if [ -D result ]; then \
		rm -rf result; \
		echo -e "$(GREEN)Removed result symlink$(NC)"; \
	fi