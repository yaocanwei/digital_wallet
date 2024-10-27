# Variables
NAME = digital_wallet
VERSION = $(shell ruby -r ./lib/digital_wallet/version.rb -e "puts DigitalWallet::VERSION")
GEM_FILE = $(NAME)-$(VERSION).gem

# Default Ruby settings
RUBY = ruby
BUNDLE = bundle
RAKE = rake

.PHONY: all setup test clean build install uninstall console help

# Default target
all: test build install

# Development setup
setup:
	@echo "Setting up development environment..."
	$(BUNDLE) install

# Run tests
test:
	@echo "Running tests..."
	$(BUNDLE) exec $(RAKE) test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f *.gem

# Build gem
build: clean
	@echo "Building gem..."
	gem build $(NAME).gemspec

# Install locally
install: build
	@echo "Installing gem locally..."
	gem install ./$(GEM_FILE)

# Uninstall local installation
uninstall:
	@echo "Uninstalling gem..."
	gem uninstall $(NAME) -v $(VERSION) -x

# Start console
console:
	@echo "Starting development console..."
	./bin/console

# Print help
help:
	@echo "Available targets:"
	@echo "  setup     - Install dependencies"
	@echo "  test      - Run tests"
	@echo "  build     - Build gem"
	@echo "  install   - Install gem locally"
	@echo "  uninstall - Uninstall local gem"
	@echo "  console   - Start development console"
	@echo "  clean     - Clean build artifacts"
