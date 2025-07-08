# Define installation directories
BINDIR = /usr/local/bin
SHAREDIR = /usr/local/share

# Define file names
SCRIPT = template_clean.sh
FRAGMENT = template_clean.script
INSTALLED_NAME = template_clean

# Default target
all:
	@echo "Use 'make install' to install the scripts."

# Install target
install: $(SCRIPT) $(FRAGMENT)
	# Install the main script to /usr/local/bin with executable permissions
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(INSTALLED_NAME)

	# Install the script fragment to /usr/local/share with read-only permissions
	install -d $(SHAREDIR)
	install -m 644 $(FRAGMENT) $(SHAREDIR)/$(INSTALLED_NAME)

# Uninstall target
uninstall:
	rm -f $(BINDIR)/$(INSTALLED_NAME)
	rm -f $(SHAREDIR)/$(INSTALLED_NAME)

# Phony targets
.PHONY: all install uninstall
