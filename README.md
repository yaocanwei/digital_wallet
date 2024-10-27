# Digital Wallet

A simple, centralized digital wallet system implemented in Ruby that supports basic wallet operations including deposits, withdrawals, transfers and balance checks.

## Features

- User can deposit money into their wallet
- User can withdraw money from their wallet
- User can send money to another user's wallet
- User can check their wallet balance
- Transaction history tracking
- Comprehensive logging system

## Architecture & Design Decisions

### System Architecture
- Modular design with clear separation of concerns
  - Models: Core data representation (Transaction, Wallet)
  - Services: Business logic (WalletSystem)
  - Utils: Support functionality (Logger)

### Technical Decisions
- Used BigDecimal for monetary values to ensure precision
- In-memory storage using Hash for simplicity
- UUID for unique transaction identification
- JSON format for standardized logging
- Pure Ruby implementation with minimal dependencies

### Error Handling
- Custom error types for different scenarios
  - InsufficientFundsError
  - UserNotFoundError
  - InvalidAmountError
- Comprehensive error logging
- Graceful error recovery

## Setup & Running

### Prerequisites
- Ruby >= 2.6.0

```bash
# Clone the repository
git clone git@github.com:yaocanwei/digital_wallet.git
cd digital_wallet

# Set execute permissions for scripts
chmod +x bin/console
chmod +x bin/setup

# Install dependencies
bundle install

# Run tests to verify setup
rake test
```

### Building & Installing Locally
```bash
# Build the gem
gem build digital_wallet.gemspec

# Install the gem locally
gem install ./digital_wallet-0.1.0.gem

# Verify installation
gem list digital_wallet
```

### Installation Options
```ruby
# Option 1: Add to your Gemfile
gem 'digital_wallet'

# Option 2: Install directly
gem install digital_wallet
```

### Interactive Development
```bash
# Start console with the gem loaded
./bin/console

# Or use IRB
irb -r digital_wallet
```

### Basic Usage
```ruby
require 'digital_wallet'

# Initialize system
wallet_system = DigitalWallet::WalletSystem.new

# Create wallets
wallet1 = wallet_system.create_wallet('user1')
wallet2 = wallet_system.create_wallet('user2')

# Deposit money
wallet_system.deposit('user1', 100)

# Transfer money
wallet_system.transfer('user1', 'user2', 50)

# Check balance
puts wallet_system.get_balance('user1') # => 50
puts wallet_system.get_balance('user2') # => 50

# Get transaction history
history = wallet_system.get_transaction_history('user1')
```

### Using with Rails
```ruby
# In your Gemfile
gem 'digital_wallet'

# Create an initializer (config/initializers/digital_wallet.rb)
WALLET_SYSTEM = DigitalWallet::WalletSystem.new

# Example controller usage
class WalletsController < ApplicationController
  def deposit
    amount = params[:amount].to_f
    WALLET_SYSTEM.deposit(current_user.id, amount)
    redirect_to wallet_path, notice: 'Deposit successful'
  rescue DigitalWallet::InvalidAmountError
    redirect_to wallet_path, alert: 'Invalid amount'
  end
end
```

## Running Tests
```bash
# Run all tests
rake test

# Run specific test file
ruby test/digital_wallet/models/wallet_test.rb
```

## Code Review Guide

### Directory Structure
```
lib/
├── digital_wallet.rb                 # Main entry point
└── digital_wallet/
    ├── version.rb                    # Version information
    ├── errors.rb                     # Custom error types
    ├── models/                       # Domain models
    │   ├── transaction.rb
    │   └── wallet.rb
    ├── services/                     # Business logic
    │   └── wallet_system.rb
    └── utils/                        # Support utilities
        └── logger.rb
```

### Review Flow
1. Start with `lib/digital_wallet.rb` to understand the system structure
2. Check `models/` for core domain objects
3. Review `services/` for business logic implementation
4. See `utils/` for supporting functionality
5. Review tests that follow the same structure as the code

## Areas for Improvement
1.Persistence layer for data storage
2.Transaction rollback mechanisms
3.User authentication and authorization
4.API documentation
5.Performance optimization for large scale usage

## Development Notes

### Time Spent
Total: 3 hours
- Planning & Design: 30 minutes
- Core Implementation: 1.5 hours
- Testing: 45 minutes
- Documentation: 15 minutes

### Features Not Implemented
Due to time constraints, the following features were not included:
- Persistent storage (currently using in-memory storage)
- User authentication/authorization
- API endpoints
- Concurrent access handling
- Transaction rollback mechanism

