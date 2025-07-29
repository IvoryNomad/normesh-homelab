# Makefile for Python virtual environment management

# Variables
REPO_ROOT = $(shell git rev-parse --show-toplevel 2>/dev/null || echo "../..")
VENV_NAME = venv
# set this to '--system-site-packages' if you wish to import system packages
# VENV_OPTS = '--system-site-packages'
VENV_PATH = $(REPO_ROOT)/$(VENV_NAME)
PYTHON = python3
PIP = $(VENV_PATH)/bin/pip
PYTHON_VENV = $(VENV_PATH)/bin/python
ANSIBLE_GALAXY = $(VENV_PATH)/bin/ansible-galaxy
REQUIREMENTS = requirements.txt
COLLECTIONS_REQUIREMENTS = requirements.yml
COLLECTIONS_PATH = $(REPO_ROOT)/ansible/collections

# Ansible collections to install (fallback if no requirements.yml)
ANSIBLE_COLLECTIONS = freeipa.ansible_freeipa ivorynomad.onepassword

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  venv                - Create virtual environment at repo root"
	@echo "  install             - Install dependencies from requirements.txt"
	@echo "  install-dev         - Install development dependencies"
	@echo "  install-collections - Install ansible-galaxy collections"
	@echo "  freeze-collections  - Generate current collections requirements.yml"
	@echo "  clean               - Remove virtual environment"
	@echo "  freeze              - Generate current requirements.txt"
	@echo "  run                 - Run your main script (customize as needed)"
	@echo "  shell               - Activate virtual environment shell"
	@echo "  info                - Show paths and current directory info"
	@echo "  setup               - Full setup: venv + dependencies + collections"

# Create virtual environment
.PHONY: venv
venv:
	@echo "Current directory: $(shell pwd)"
	@echo "Repository root: $(REPO_ROOT)"
	@echo "Virtual environment will be created at: $(VENV_PATH)"
	@if [ ! -d "$(VENV_PATH)" ]; then \
		echo "Creating virtual environment..."; \
		$(PYTHON) -m venv $(VENV_OPTS) $(VENV_PATH); \
		echo "Virtual environment created at $(VENV_PATH)"; \
	else \
		echo "Virtual environment already exists at $(VENV_PATH)"; \
	fi

# Install dependencies from requirements.txt
.PHONY: install
install: venv
	@if [ -f "$(REQUIREMENTS)" ]; then \
		echo "Installing dependencies from $(REQUIREMENTS)..."; \
		$(PIP) install --upgrade pip setuptools wheel; \
		$(PIP) install -r $(REQUIREMENTS); \
	else \
		echo "No $(REQUIREMENTS) file found. Creating empty one..."; \
		touch $(REQUIREMENTS); \
		$(PIP) install --upgrade pip setuptools wheel; \
	fi

# Install ansible-galaxy collections
.PHONY: install-collections
install-collections: install
	@echo "Installing ansible-galaxy collections..."
	@if [ -f "$(ANSIBLE_GALAXY)" ]; then \
		echo "Creating collections directory at $(COLLECTIONS_PATH)..."; \
		mkdir -p $(COLLECTIONS_PATH); \
		if [ -f "$(COLLECTIONS_REQUIREMENTS)" ]; then \
			echo "Installing collections from $(COLLECTIONS_REQUIREMENTS)..."; \
			$(ANSIBLE_GALAXY) collection install -r $(COLLECTIONS_REQUIREMENTS) -p $(COLLECTIONS_PATH) --force; \
		else \
			echo "No $(COLLECTIONS_REQUIREMENTS) found. Installing default collections: $(ANSIBLE_COLLECTIONS)"; \
			$(ANSIBLE_GALAXY) collection install $(ANSIBLE_COLLECTIONS) -p $(COLLECTIONS_PATH) --force; \
			echo "Consider running 'make freeze-collections' to create $(COLLECTIONS_REQUIREMENTS)"; \
		fi; \
		echo "Ansible collections installed successfully in $(COLLECTIONS_PATH)"; \
		echo "Note: Add 'collections' to ansible/.gitignore if not already present"; \
	else \
		echo "Error: ansible-galaxy not found. Make sure ansible is installed."; \
		exit 1; \
	fi

# Generate requirements.yml from currently installed collections
.PHONY: freeze-collections
freeze-collections: venv
	@echo "Generating $(COLLECTIONS_REQUIREMENTS) from collections in $(COLLECTIONS_PATH)..."
	@echo "---" > $(COLLECTIONS_REQUIREMENTS)
	@echo "collections:" >> $(COLLECTIONS_REQUIREMENTS)
	@$(ANSIBLE_GALAXY) collection list -p $(COLLECTIONS_PATH) --format yaml 2>/dev/null | grep -E "^  [a-zA-Z]" | sed 's/^  /  - name: /' | sed 's/:.*$$//' >> $(COLLECTIONS_REQUIREMENTS) || echo "  # No collections installed yet" >> $(COLLECTIONS_REQUIREMENTS)
	@echo "Collections requirements saved to $(COLLECTIONS_REQUIREMENTS)"

# Install development dependencies (customize as needed)
.PHONY: install-dev
install-dev: venv
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install pytest black flake8 mypy
	@if [ -f "requirements-dev.txt" ]; then \
		$(PIP) install -r requirements-dev.txt; \
	fi

# Clean up virtual environment
.PHONY: clean
clean:
	@if [ -d "$(VENV_PATH)" ]; then \
		echo "Removing virtual environment at $(VENV_PATH)..."; \
		rm -rf $(VENV_PATH); \
		echo "Virtual environment removed"; \
	else \
		echo "No virtual environment to remove at $(VENV_PATH)"; \
	fi

# Generate requirements.txt from current environment
.PHONY: freeze
freeze: venv
	$(PIP) freeze > $(REQUIREMENTS)
	@echo "Requirements saved to $(REQUIREMENTS)"

# Activate shell (this will show the command to run)
.PHONY: shell
shell: venv
	@echo "To activate the virtual environment, run:"
	@echo "source $(VENV_PATH)/bin/activate"

# Show directory and path information
.PHONY: info
info:
	@echo "Current working directory: $(shell pwd)"
	@echo "Repository root: $(REPO_ROOT)"
	@echo "Virtual environment path: $(VENV_PATH)"
	@echo "Python executable: $(PYTHON)"
	@echo "Pip executable: $(PIP)"
	@echo "Ansible Galaxy executable: $(ANSIBLE_GALAXY)"
	@echo "Collections path: $(COLLECTIONS_PATH)"
	@echo "Collections requirements file: $(COLLECTIONS_REQUIREMENTS)"
	@echo "Fallback collections: $(ANSIBLE_COLLECTIONS)"

# Quick setup target that creates venv, installs dependencies, and installs collections
.PHONY: setup
setup: venv install install-collections shell
	@echo "Setup complete! Virtual environment ready to use."
