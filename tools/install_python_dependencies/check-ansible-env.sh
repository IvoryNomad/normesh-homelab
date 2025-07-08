#!/bin/bash

# Ansible Environment Detection Script

# Usage: ./check-ansible-env.sh [–status]

set -e

# Configuration

VENV_DIR="ansible_venv"
PYTHON="python3"

# Colors

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

show_status() {
  echo -e "${YELLOW}Ansible Environment Status:${NC}"

  if command -v ansible &> /dev/null; then
    echo "  Ansible version: $(ansible --version | head -n1)"
    echo "  Ansible path: $(command -v ansible)"
    
    if [[ -n "$VIRTUAL_ENV" ]]; then
      echo "  Virtual environment: $VIRTUAL_ENV"
    fi
    
    ANSIBLE_MODULE_PATH=$(${PYTHON} -c "import ansible; print(ansible.__file__)" 2>/dev/null || echo "unknown")
    echo "  Module path: $ANSIBLE_MODULE_PATH"
    
    # Show current Python environment
    echo "  Python executable: $(command -v python)"
    echo "  Python version: $(python --version 2>&1)"
    
  else
    echo -e "  ${RED}Ansible not found${NC}"
  fi

  echo "  Detection files:"
  if ls .ansible-* 1> /dev/null 2>&1; then
    for file in .ansible-*; do
      echo "    $file"
    done
  else
    echo "    No detection files found"
  fi
}

detect_ansible_environment() {
  echo -e "${YELLOW}Detecting Ansible environment…${NC}"

  # Clean up old detection files
  rm -f .ansible-*

  # Check if ansible command is available
  if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Ansible not found. Creating virtual environment...${NC}"
    
    # Create virtual environment
    if [[ ! -d "$VENV_DIR" ]]; then
        $PYTHON -m venv $VENV_DIR
    fi
    
    # Activate and install ansible
    source $VENV_DIR/bin/activate
    pip install --upgrade pip
    pip install ansible
    
    echo -e "${GREEN}Virtual environment created: $VENV_DIR${NC}"
    echo -e "${YELLOW}To activate manually: source $VENV_DIR/bin/activate${NC}"
    touch .ansible-venv-created
    return
  fi

  # Get ansible executable path
  ANSIBLE_CMD_PATH=$(command -v ansible)

  # Check if we're in a virtual environment
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -e "${GREEN}Using existing virtual environment: $VIRTUAL_ENV${NC}"
    echo "Ansible path: $ANSIBLE_CMD_PATH"
    touch .ansible-venv-detected
    return
  fi

  # Check ansible module location for more accurate detection
  ANSIBLE_MODULE_PATH=$(${PYTHON} -c "import ansible; print(ansible.__file__)" 2>/dev/null || echo "")

  if [[ "$ANSIBLE_MODULE_PATH" == *"/.local/"* ]]; then
    echo -e "${GREEN}Ansible installed in user space${NC}"
    echo "Ansible module path: $ANSIBLE_MODULE_PATH"
    echo "Ansible command path: $ANSIBLE_CMD_PATH"
    touch .ansible-user-detected
  elif [[ "$ANSIBLE_CMD_PATH" == *"/.local/"* ]]; then
    echo -e "${GREEN}Ansible command in user space${NC}"
    echo "Ansible command path: $ANSIBLE_CMD_PATH"
    echo "Ansible module path: $ANSIBLE_MODULE_PATH"
    touch .ansible-user-detected
  else
    echo -e "${YELLOW}System ansible detected - will use --user for safety${NC}"
    echo "Ansible command path: $ANSIBLE_CMD_PATH"
    echo "Ansible module path: $ANSIBLE_MODULE_PATH"
    touch .ansible-system-detected
  fi
}

validate_environment() {
  # Ensure we can actually import ansible
  if ! $PYTHON -c "import ansible" &> /dev/null; then
  echo -e "${RED}Error: Cannot import ansible module${NC}"
  exit 1
  fi

  # Test basic ansible functionality
  if ! ansible --version &> /dev/null; then
    echo -e "${RED}Error: Ansible command not working properly${NC}"
    exit 1
  fi

  echo -e "${GREEN}Ansible environment validation passed${NC}"
}

# Main execution

case "${1:-}" in
  "–status"|"-s")
    show_status
    ;;
  "–validate"|"-v")
    validate_environment
    ;;
  "–help"|"-h")
    echo "Usage: $0 [OPTION]"
    echo "Detect and setup Ansible environment"
    echo ""
    echo "Options:"
    echo "  –status, -s     Show current environment status"
    echo "  –validate, -v   Validate current environment"
    echo "  –help, -h       Show this help message"
    echo ""
    echo "When run without options, detects and sets up the Ansible environment."
    ;;
  *)
    detect_ansible_environment
    validate_environment
    ;;
esac
