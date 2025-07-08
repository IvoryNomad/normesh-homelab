# Define installation directories
BINDIR = ${HOME}/.local/bin

# Define file names
SCRIPT = op_wrapper.sh
INSTALLED_NAME = op_wrapper

# Default target
all:
	@echo "Use 'make install' to install the script."

# Install target
install: $(SCRIPT)
	# Install the script to BINDIR with executable permissions
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(INSTALLED_NAME)

# Uninstall target
uninstall:
	rm -f $(BINDIR)/$(INSTALLED_NAME)

# Phony targets
.PHONY: all install uninstall
