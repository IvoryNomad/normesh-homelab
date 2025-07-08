# Ansible Environment Setup Makefile

.PHONY: setup check-ansible install-deps clean help status test-ansible dev-setup
.DEFAULT_GOAL := setup

# Configuration

VENV_DIR := venv
REQUIREMENTS_FILE := requirements.txt
CHECK_SCRIPT := scripts/check-ansible-env.sh
PYTHON := python3

# Colors

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

help: ## Show this help message
	@echo “Available targets:”
	@grep -E ‘^[a-zA-Z_-]+:.*?## .*$$’ $(MAKEFILE_LIST) | sort | awk ‘BEGIN {FS = “:.*?## “}; {printf “  $(GREEN)%-15s$(NC) %s\n”, $$1, $$2}’

setup: check-ansible install-deps ## Setup ansible environment and install dependencies

check-ansible: $(CHECK_SCRIPT) ## Check and setup ansible environment
	@echo “$(YELLOW)Checking Ansible installation…$(NC)”
	@$(CHECK_SCRIPT)

install-deps: ## Install project dependencies based on ansible environment
	@echo “$(YELLOW)Installing dependencies…$(NC)”
	@if [ -f “.ansible-venv-created” ]; then   
		echo “Installing dependencies in created virtual environment…”;   
		if [ -f “$(REQUIREMENTS_FILE)” ]; then   
			$(VENV_DIR)/bin/pip install -r $(REQUIREMENTS_FILE);   
		else   
			echo “No $(REQUIREMENTS_FILE) found, skipping dependency installation”;   
		fi;   
	elif [ -f “.ansible-venv-detected” ]; then   
		echo “Installing dependencies in existing virtual environment…”;   
		if [ -f “$(REQUIREMENTS_FILE)” ]; then   
			pip install -r $(REQUIREMENTS_FILE);   
		else   
			echo “No $(REQUIREMENTS_FILE) found, skipping dependency installation”;   
		fi;   
	elif [ -f “.ansible-user-detected” ] || [ -f “.ansible-system-detected” ]; then   
		echo “Installing dependencies with –user flag…”;   
		if [ -f “$(REQUIREMENTS_FILE)” ]; then   
			$(PYTHON) -m pip install –user -r $(REQUIREMENTS_FILE);   
		else   
			echo “No $(REQUIREMENTS_FILE) found, skipping dependency installation”;   
		fi;   
	else   
		echo “$(RED)Error: Ansible environment not detected. Run ‘make check-ansible’ first.$(NC)”;   
		exit 1;   
	fi
	@echo “$(GREEN)Dependencies installed successfully!$(NC)”

status: $(CHECK_SCRIPT) ## Show current ansible environment status
	@$(CHECK_SCRIPT) –status

clean: ## Clean up generated files and virtual environment
	@echo “$(YELLOW)Cleaning up…$(NC)”
	rm -rf $(VENV_DIR)
	rm -f .ansible-*
	@echo “$(GREEN)Cleanup complete$(NC)”

test-ansible: ## Test ansible installation
	@echo “$(YELLOW)Testing Ansible installation…$(NC)”
	@if [ -f “.ansible-venv-created” ]; then   
		$(VENV_DIR)/bin/ansible –version;   
	else   
		ansible –version;   
	fi

# Development aliases

dev-setup: setup ## Setup development environment (alias for setup)

# Ensure the check script is executable

$(CHECK_SCRIPT):
	@if [ ! -f “$(CHECK_SCRIPT)” ]; then   
		echo “$(RED)Error: $(CHECK_SCRIPT) not found!$(NC)”;   
		echo “Please ensure the script exists and is committed to the repository.”;   
		exit 1;   
	fi
	@chmod +x $(CHECK_SCRIPT)
