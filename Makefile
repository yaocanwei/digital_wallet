# Variables
NAME = digital_wallet
VERSION = $(shell ruby -r ./lib/digital_wallet/version.rb -e "puts DigitalWallet::VERSION")
GEM_FILE = $(NAME)-$(VERSION).gem

# Default Ruby settings
RUBY = ruby
BUNDLE = bundle
RAKE = rake

# Directories
LIB_DIR = lib
TEST_DIR = test
DIST_DIR = dist
TMP_DIR = tmp

# Remote settings (customize these)
REMOTE_HOST = your.remote.host
REMOTE_USER = deploy
REMOTE_PATH = /opt/apps/$(NAME)

.PHONY: all setup test clean build package deploy

# Default target
all: setup test build

# Development setup
setup:
	@echo "Setting up development environment..."
	$(BUNDLE) install
	mkdir -p $(DIST_DIR) $(TMP_DIR)

# Run tests
test:
	@echo "Running tests..."
	$(BUNDLE) exec $(RAKE) test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(DIST_DIR)/* $(TMP_DIR)/* *.gem
	$(BUNDLE) clean --force

# Build gem
build: clean
	@echo "Building gem..."
	$(BUNDLE) exec rake build
	mv pkg/$(GEM_FILE) $(DIST_DIR)/

# Create distribution package
package: build
	@echo "Creating distribution package..."
	mkdir -p $(TMP_DIR)/$(NAME)
	cp -r lib Gemfile Gemfile.lock README.md $(TMP_DIR)/$(NAME)/
	cd $(TMP_DIR) && tar -czf ../$(DIST_DIR)/$(NAME)-$(VERSION).tar.gz $(NAME)
	@echo "Package created: $(DIST_DIR)/$(NAME)-$(VERSION).tar.gz"

# Deploy to remote server
deploy: package
	@echo "Deploying to remote server..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "mkdir -p $(REMOTE_PATH)/releases/$(VERSION)"
	scp $(DIST_DIR)/$(NAME)-$(VERSION).tar.gz $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_PATH)/releases/$(VERSION)/
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "cd $(REMOTE_PATH)/releases/$(VERSION) && \
		tar -xzf $(NAME)-$(VERSION).tar.gz && \
		cd $(NAME) && \
		bundle install --without development test && \
		ln -sfn $(REMOTE_PATH)/releases/$(VERSION)/$(NAME) $(REMOTE_PATH)/current"

# Install locally
install: build
	@echo "Installing gem locally..."
	gem install $(DIST_DIR)/$(GEM_FILE)

# Uninstall local installation
uninstall:
	@echo "Uninstalling gem..."
	gem uninstall $(NAME) -v $(VERSION) -x

# Development tasks
console:
	@echo "Starting development console..."
	$(BUNDLE) exec bin/console

# Docker support (if needed)
docker-build:
	docker build -t $(NAME):$(VERSION) .

docker-run:
	docker run -it --rm $(NAME):$(VERSION)

# Local development server (if needed)
server:
	$(BUNDLE) exec bin/server

# Check code style
lint:
	$(BUNDLE) exec rubocop

# Generate documentation
docs:
	$(BUNDLE) exec yard doc

# Print help
help:
	@echo "Available targets:"
	@echo "  setup      - Install dependencies"
	@echo "  test       - Run tests"
	@echo "  build      - Build gem"
	@echo "  package    - Create distribution package"
	@echo "  deploy     - Deploy to remote server"
	@echo "  install    - Install gem locally"
	@echo "  uninstall  - Uninstall local gem"
	@echo "  clean      - Clean build artifacts"
	@echo "  console    - Start development console"
	@echo "  lint       - Check code style"
	@echo "  docs       - Generate documentation"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run Docker container"

# Version tasks
version:
	@echo "Current version: $(VERSION)"

bump-patch:
	@echo "Bumping patch version..."
	$(RUBY) -i -pe '$$_.gsub!(/VERSION = "(.*?)"/, "VERSION = \"#{$$1.split(\".\").tap{|v| v[-1] = v[-1].to_i + 1}.join(\".\")}\"")' lib/$(NAME)/version.rb

bump-minor:
	@echo "Bumping minor version..."
	$(RUBY) -i -pe '$$_.gsub!(/VERSION = "(.*?)"/, "VERSION = \"#{$$1.split(\".\").tap{|v| v[1] = v[1].to_i + 1; v[2] = "0"}.join(\".\")}\"")' lib/$(NAME)/version.rb

bump-major:
	@echo "Bumping major version..."
	$(RUBY) -i -pe '$$_.gsub!(/VERSION = "(.*?)"/, "VERSION = \"#{$$1.split(\".\").tap{|v| v[0] = v[0].to_i + 1; v[1] = "0"; v[2] = "0"}.join(\".\")}\"")' lib/$(NAME)/version.rb
