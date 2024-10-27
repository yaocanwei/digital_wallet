require 'bigdecimal'
require 'time'
require 'securerandom'
require_relative 'logger'

module DigitalWallet
  class InsufficientFundsError < StandardError; end
  class UserNotFoundError < StandardError; end
  class InvalidAmountError < StandardError; end

  class Transaction
    attr_reader :id, :from_user, :to_user, :amount, :transaction_type, :timestamp

    def initialize(from_user:, to_user:, amount:, transaction_type:)
      @id = SecureRandom.uuid
      @from_user = from_user
      @to_user = to_user
      @amount = BigDecimal(amount.to_s)
      @transaction_type = transaction_type
      @timestamp = Time.now
    end

    def to_log_format
      {
        transaction_id: id,
        from_user: from_user,
        to_user: to_user,
        amount: amount.to_s('F'),
        type: transaction_type,
        timestamp: timestamp.iso8601(3)
      }
    end
  end

  class Wallet
    attr_reader :user_id, :transactions
    
    def initialize(user_id)
      @user_id = user_id
      @transactions = []
      @balance = BigDecimal('0')
    end

    def balance
      @balance
    end

    def add_transaction(transaction)
      @transactions << transaction
    end

    def update_balance(amount)
      @balance += amount
    end

    def to_log_format
      {
        user_id: user_id,
        balance: balance.to_s('F'),
        transaction_count: transactions.size
      }
    end
  end

  class WalletSystem
    def initialize(logger = nil)
      @wallets = {}
      @logger = logger || WalletLogger.new
    end

    def create_wallet(user_id)
      @logger.log(:info, 'wallet_created', { user_id: user_id })
      @wallets[user_id] ||= Wallet.new(user_id)
    end

    def deposit(user_id, amount)
      validate_amount(amount)
      wallet = find_or_create_wallet(user_id)
      
      transaction = Transaction.new(
        from_user: nil,
        to_user: user_id,
        amount: amount,
        transaction_type: 'deposit'
      )

      wallet.add_transaction(transaction)
      wallet.update_balance(amount)

      @logger.log(:info, 'deposit_successful', {
        user_id: user_id,
        amount: amount.to_s,
        transaction: transaction.to_log_format,
        wallet: wallet.to_log_format
      })

      transaction

    rescue StandardError => e
      @logger.log(:error, 'deposit_failed', {
        user_id: user_id,
        amount: amount.to_s,
        error: e.message,
        backtrace: e.backtrace[0..5]
      })
      raise
    end

    def withdraw(user_id, amount)
      validate_amount(amount)
      wallet = find_wallet(user_id)
      
      raise InsufficientFundsError if wallet.balance < amount

      transaction = Transaction.new(
        from_user: user_id,
        to_user: nil,
        amount: -amount,
        transaction_type: 'withdraw'
      )

      wallet.add_transaction(transaction)
      wallet.update_balance(-amount)

      @logger.log(:info, 'withdrawal_successful', {
        user_id: user_id,
        amount: amount.to_s,
        transaction: transaction.to_log_format,
        wallet: wallet.to_log_format
      })

      transaction
    rescue StandardError => e
      @logger.log(:error, 'withdrawal_failed', {
        user_id: user_id,
        amount: amount.to_s,
        error: e.message,
        backtrace: e.backtrace[0..5]
      })
      raise
    end

    def transfer(from_user_id, to_user_id, amount)
      validate_amount(amount)
      from_wallet = find_wallet(from_user_id)
      to_wallet = find_or_create_wallet(to_user_id)

      raise InsufficientFundsError if from_wallet.balance < amount

      transaction = Transaction.new(
        from_user: from_user_id,
        to_user: to_user_id,
        amount: amount,
        transaction_type: 'transfer'
      )

      from_wallet.add_transaction(transaction)
      to_wallet.add_transaction(transaction)
      
      from_wallet.update_balance(-amount)
      to_wallet.update_balance(amount)

      @logger.log(:info, 'transfer_successful', {
        transaction: transaction.to_log_format,
        from_wallet: from_wallet.to_log_format,
        to_wallet: to_wallet.to_log_format
      })

      transaction
    rescue StandardError => e
      @logger.log(:error, 'transfer_failed', {
        from_user_id: from_user_id,
        to_user_id: to_user_id,
        amount: amount.to_s,
        error: e.message,
        backtrace: e.backtrace[0..5]
      })
      raise
    end

    def get_balance(user_id)
      wallet = find_wallet(user_id)
      @logger.log(:info, 'balance_checked', wallet.to_log_format)
      wallet.balance

    rescue StandardError => e
      @logger.log(:error, 'balance_check_failed', {
        user_id: user_id,
        error: e.message
      })
      raise
    end

    def get_transaction_history(user_id)
      wallet = find_wallet(user_id)

      @logger.log(:info, 'transaction_history_retrieved', {
        user_id: user_id,
        transaction_count: wallet.transactions.size
      })
      
      wallet.transactions

    rescue StandardError => e
      @logger.log(:error, 'transaction_history_retrieval_failed', {
        user_id: user_id,
        error: e.message
      })
      raise
    end

    private

    def find_wallet(user_id)
      @wallets[user_id] or raise UserNotFoundError, "User #{user_id} not found"
    end

    def find_or_create_wallet(user_id)
      @wallets[user_id] ||= Wallet.new(user_id)
    end

    def validate_amount(amount)
      raise InvalidAmountError unless amount.is_a?(Numeric) && amount.positive?
    end
  end
end
