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

### Installation
```ruby
# Add to your Gemfile
gem 'digital_wallet'

# Or install directly
gem install digital_wallet
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

1. Transaction Security & Status Management
   - Add transaction status (pending, confirmed, failed, cancelled)
   - Implement unique transaction ID (nonce) to prevent double-spending
   - Add digital signature support for transaction verification
   - Support transaction metadata for payment references and notes

2. Enhanced Balance Management
   - Support multiple balance types (total, available, pending, reserved)
   - Implement transaction limits (daily, per-transaction)
   - Add fee management system
   - Support balance snapshots for auditing

3. Account Security Features
   - Implement address whitelisting for trusted recipients
   - Add two-factor authentication support
   - Support multi-signature for high-value transactions
   - Add account recovery mechanisms

4. Compliance & Audit System
   - Maintain comprehensive audit trails
   - Add KYC/AML support with verification levels
   - Implement transaction monitoring and reporting
   - Support blacklist checking

5. System Scalability
   - Add database persistence layer
   - Implement event system for transaction tracking
   - Support batch operations for multiple transfers
   - Add API rate limiting and authentication

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

