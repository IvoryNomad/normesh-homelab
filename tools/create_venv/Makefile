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
REQUIREMENTS = requirements.txt

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  venv          - Create virtual environment at repo root"
	@echo "  install       - Install dependencies from requirements.txt"
	@echo "  install-dev   - Install development dependencies"
	@echo "  clean         - Remove virtual environment"
	@echo "  freeze        - Generate current requirements.txt"
	@echo "  run           - Run your main script (customize as needed)"
	@echo "  shell         - Activate virtual environment shell"
	@echo "  info          - Show paths and current directory info"

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

# Quick setup target that creates venv and installs dependencies
.PHONY: setup
setup: venv install shell
	@echo "Setup complete! Virtual environment ready to use."
