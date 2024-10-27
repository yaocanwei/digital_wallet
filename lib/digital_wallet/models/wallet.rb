# lib/digital_wallet/models/wallet.rb
require 'bigdecimal'

module DigitalWallet
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
end
